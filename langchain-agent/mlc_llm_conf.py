import os
import re
import asyncio
import shlex
import time
from typing import Any, List, Optional

from langchain.schema import (
    AIMessage,
    BaseMessage,
    ChatResult,
    ChatGeneration,
)
from langchain.chat_models.base import BaseChatModel


# -------------------------------
# Env Vars
# -------------------------------
MODEL_PATH = os.environ.get("MLC_MODEL_PATH", "")
MODEL_LIB = os.environ.get("MODEL_LIB", "")
MLC_DEVICE = os.environ.get("MLC_DEVICE", "opencl")
MODEL_NAME = os.environ.get("MODEL_NAME", "MLC_LLM_Model")
CLI_BIN = os.environ.get("MLC_CLI_BIN", "/workspace/mlc-llm/build/apps/mlc_cli_chat/mlc_cli_chat")
TIMEOUT = int(os.environ.get("MLC_TIMEOUT", "20")) * 60  # default 1 minute


def sanitize_prompt(text: str) -> str:
    """
    Sanitize a prompt for safe CLI use with --with-prompt.
    - Removes newlines and carriage returns
    - Strips dangerous quotes/backticks
    - Collapses multiple spaces
    - Keeps meaningful math symbols (*, ^, |, /, π, <, >, =)
    """
    # Remove newlines and carriage returns
    text = text.replace("\n", " ").replace("\r", " ")

    # Remove quotes/backticks that can break shell
    text = re.sub(r"[\"'`]", "", text)

    # Allow only safe characters (letters, numbers, spaces, punctuation, math symbols)
    text = re.sub(r"[^a-zA-Z0-9\s\*\^\|\(\)\[\]\{\}\/\+\-\=\.:\?,π<>]", "", text)

    # Collapse multiple spaces
    text = re.sub(r"\s+", " ", text).strip()

    return text


# -------------------------------
# Prompt Utilities
# -------------------------------
def build_mlc_prompt(messages: list) -> str:
    """messages: LangChain-style; we'll pull first SystemMessage and last HumanMessage.
       Expect the HumanMessage.content to ALREADY contain the context block if you have one.
    """
    system_msg = None
    user_msg = None

    from langchain.schema import SystemMessage, HumanMessage  # adjust import if different

    for m in messages:
        if isinstance(m, SystemMessage) and not system_msg:
            system_msg = m.content.strip().replace("\n", " ")
        elif isinstance(m, HumanMessage):
            user_msg = m.content.strip().replace("\n", " ")

    if not user_msg:
        raise ValueError("No user message found.")

    # Make the system concise and assertive (not over-restrictive)
    system_msg = (system_msg or
                  "You are a helpful assistant. Answer using the provided context. ")

    # Llama-3 header ids, no newlines (your Variant-2 style with spaces)
    return (
        f"<|start_header_id|>system<|end_header_id|> {system_msg} <|eot_id|>"
        f"<|start_header_id|>user<|end_header_id|> {user_msg} <|eot_id|>"
        f"<|start_header_id|>assistant<|end_header_id|>"
    )



# -------------------------------
# LangChain Wrapper
# -------------------------------
class MLCLLM(BaseChatModel):
    model: str = MODEL_NAME
    callback_handler: Optional[Any] = None

    async def _agenerate(
        self,
        messages: List[BaseMessage],
        stop: Optional[List[str]] = None,
        run_manager: Optional[Any] = None,
        **kwargs: Any,
    ) -> ChatResult:
            prompt = shlex.quote(sanitize_prompt(build_mlc_prompt(messages)))
            cmd = [
                CLI_BIN,
                "--model", MODEL_PATH,
                "--model-lib", MODEL_LIB,
                "--device", MLC_DEVICE,
                "--with-prompt", prompt,
            ]
            print(f"cmd - {cmd}", flush=True)

            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.DEVNULL,
            )

            start_time = time.monotonic()
            deadline = start_time + TIMEOUT

            collected_text = ""
            comma_count = 0
            capturing = False
            try:
                while True:
                    chunk = await process.stdout.read(64)  # read a bit more than 1 byte
                    if not chunk:
                        break
                    line = chunk.decode("utf-8", errors="ignore")

                    # timeout check
                    if time.monotonic() >= deadline:
                        if process.returncode is None:
                            process.kill()
                        collected_text += f"[Timeout after {TIMEOUT}s]"
                        break


                    if '"""' in line or '""' in line:
                        comma_count += 1
                        continue
                    if comma_count > 1:
                        capturing = True
                    if 'decode :' in line:
                        capturing = False
                        comma_count = 0
                        line = line.split("decode :")[0]


                    if not capturing:
                        continue

                    # Token streaming
                    if run_manager:
                        await run_manager.on_llm_new_token(line, verbose=False)
                    if self.callback_handler and hasattr(self.callback_handler, "on_llm_new_token"):
                        for word in re.findall(r"\S+|\s", line):
                            if word == "\n":
                                token = "\n"  # send explicit newline marker
                            else:
                                token = word
                            await asyncio.sleep(0.1)
                            maybe_coro = self.callback_handler.on_llm_new_token(token, verbose=False)
                            if asyncio.iscoroutine(maybe_coro):
                                await maybe_coro

                    collected_text += line

                # Close callback
                if self.callback_handler and hasattr(self.callback_handler, "on_llm_end"):
                    maybe_coro = self.callback_handler.on_llm_end({}, verbose=False)
                    if asyncio.iscoroutine(maybe_coro):
                        await maybe_coro
                message = AIMessage(content=collected_text.strip())
            finally:
                if process.returncode is None:
                    process.kill()
                await process.wait()
            return ChatResult(generations=[ChatGeneration(message=message or AIMessage(content=""))])

    # ✅ Key fix: Do not call asyncio.run()
    async def _generate(
        self, messages: List[BaseMessage], **kwargs: Any
    ) -> ChatResult:
        pass
        # return await self._agenerate(messages, **kwargs)

    @property
    def _llm_type(self) -> str:
        return "mlc"

# Converted from Python to NoodleCore
# Original file: src

import asyncio
import json
import logging
import os
import datetime.datetime
import pathlib.Path
import typing.Any

import .translator.PythonTranslator

# IDE integration imports
try
    #     import aiohttp
    #     from aiohttp import web
except ImportError:
    aiohttp = None
    web = None


class IDEIntegration
    #     """Integration layer between transpiler and IDE."""

    #     def __init__(self, host: str = "localhost", port: int = 8080):
    self.host = host
    self.port = port
    self.session = None
    self.logger = logging.getLogger(__name__)

    #     async def connect_to_ide(self) -bool):
    #         """Connect to IDE backend."""
    #         try:
    #             if not aiohttp:
                    self.logger.warning("aiohttp not available, using fallback")
    #                 return False

    self.session = aiohttp.ClientSession()

    #             # Test connection
    #             async with self.session.get(
    #                 f"http://{self.host}:{self.port}/health"
    #             ) as response:
    #                 if response.status = 200:
                        self.logger.info("Successfully connected to IDE")
    #                     return True
    #                 else:
                        self.logger.warning(f"IDE connection failed: {response.status}")
    #                     return False

    #         except Exception as e:
                self.logger.error(f"Failed to connect to IDE: {e}")
    #             return False

    #     async def send_transpile_result(self, result: Dict[str, Any]) -bool):
    #         """Send transpilation result to IDE."""
    #         try:
    #             if not self.session:
                    await self.connect_to_ide()

    #             if not self.session:
                    self.logger.warning("No IDE session available")
    #                 return False

    #             async with self.session.post(
    #                 f"http://{self.host}:{self.port}/api/transpiler/result",
    json = result,
    headers = {"Content-Type": "application/json"},
    #             ) as response:
    return response.status = 200

    #         except Exception as e:
                self.logger.error(f"Failed to send transpile result: {e}")
    #             return False

    #     async def request_file_content(self, file_path: str) -Optional[str]):
    #         """Request file content from IDE."""
    #         try:
    #             if not self.session:
                    await self.connect_to_ide()

    #             if not self.session:
                    self.logger.warning("No IDE session available")
    #                 return None

    #             async with self.session.get(
    #                 f"http://{self.host}:{self.port}/api/file/content",
    params = {"path": file_path},
    #             ) as response:
    #                 if response.status = 200:
    data = await response.json()
                        return data.get("content")
    #                 return None

    #         except Exception as e:
                self.logger.error(f"Failed to request file content: {e}")
    #             return None

    #     async def notify_progress(self, progress: float, message: str = "") -bool):
    #         """Notify IDE of transpilation progress."""
    #         try:
    #             if not self.session:
                    await self.connect_to_ide()

    #             if not self.session:
    #                 return False

    payload = {
    #                 "progress": progress,
    #                 "message": message,
                    "timestamp": datetime.now().isoformat(),
    #             }

    #             async with self.session.post(
    #                 f"http://{self.host}:{self.port}/api/transpiler/progress",
    json = payload,
    headers = {"Content-Type": "application/json"},
    #             ) as response:
    return response.status = 200

    #         except Exception as e:
                self.logger.error(f"Failed to notify progress: {e}")
    #             return False


class EnhancedPythonTranslator(PythonTranslator)
    #     """Enhanced Python translator with IDE integration."""

    #     def __init__(self, ide_integration: Optional[IDEIntegration] = None):
            super().__init__()
    self.ide_integration = ide_integration or IDEIntegration()
    self.logger = logging.getLogger(__name__)

    #     async def translate_with_ide_integration(
    self, source: str, file_path: str = None
    #     ) -Dict[str, Any]):
    #         """Translate Python source with IDE integration."""
    #         try:
    #             # Notify start
                await self.ide_integration.notify_progress(0.1, "Starting translation")

    #             # Perform translation
    noodle_code = self.translate(source)

    #             # Notify progress
                await self.ide_integration.notify_progress(0.8, "Translation complete")

    #             # Prepare result
    result = {
    #                 "success": True,
    #                 "noodle_code": noodle_code,
    #                 "original_source": source,
    #                 "file_path": file_path,
                    "timestamp": datetime.now().isoformat(),
    #                 "statistics": {
                        "original_lines": len(source.split("\n")),
                        "noodle_lines": len(noodle_code.split("\n")),
                        "compression_ratio": (
    #                         len(noodle_code) / len(source) if source else 1
    #                     ),
    #                 },
    #             }

    #             # Send to IDE
                await self.ide_integration.send_transpile_result(result)

    #             # Notify completion
                await self.ide_integration.notify_progress(1.0, "Translation completed")

    #             return result

    #         except Exception as e:
    error_result = {
    #                 "success": False,
                    "error": str(e),
    #                 "file_path": file_path,
                    "timestamp": datetime.now().isoformat(),
    #             }

                await self.ide_integration.send_transpile_result(error_result)
                self.logger.error(f"Translation failed: {e}")
    #             raise


function generate_ndl(source, output_path, ide_integration: Optional[IDEIntegration] = None)
    #     """
    #     Generate Noodle .ndl file from Python source.

    #     Args:
    #         source: Python source code
    #         output_path: Path to output .ndl file
    #         ide_integration: Optional IDE integration instance
    #     """
    #     try:
    translator = EnhancedPythonTranslator(ide_integration)

    #         # Translate with IDE integration
    result = asyncio.run(translator.translate_with_ide_integration(source))

    #         if result["success"]:
    #             # Basic formatting: Join lines, ensure proper indentation
    formatted_code = result["noodle_code"]

    #             # Ensure output directory exists
    output_path_obj = Path(output_path)
    output_path_obj.parent.mkdir(parents = True, exist_ok=True)

    #             # Write to file
    #             with open(output_path, "w", encoding="utf-8") as f:
                    f.write(formatted_code)

                print(f"Generated Noodle code at {output_path}")
                print(f"Statistics: {result['statistics']}")

    #             return result
    #         else:
                print(f"Translation failed: {result['error']}")
    #             return result

    #     except Exception as e:
            print(f"Error generating NDL: {e}")
            return {"success": False, "error": str(e)}


def generate_ndl_with_ide(
source, output_path, host: str = "localhost", port: int = 8080
# ):
#     """
#     Generate Noodle .ndl file with IDE integration.

#     Args:
#         source: Python source code
#         output_path: Path to output .ndl file
#         host: IDE host address
#         port: IDE port
#     """
ide_integration = IDEIntegration(host, port)
    return generate_ndl(source, output_path, ide_integration)


# Web server for IDE communication
# async def create_transpiler_server(host: str = "localhost", port: int = 8081):
#     """Create web server for IDE-transpiler communication."""
app = web.Application()

#     # Transpilation endpoint
#     async def transpile_handler(request):
#         try:
data = await request.json()
source = data.get("source", "")
file_path = data.get("file_path")

translator = EnhancedPythonTranslator()
result = await translator.translate_with_ide_integration(source, file_path)

            return web.json_response(result)

#         except Exception as e:
return web.json_response({"success": False, "error": str(e)}, status = 500)

#     # File content endpoint
#     async def file_content_handler(request):
#         try:
file_path = request.query.get("path")
#             if not file_path:
return web.json_response({"error": "File path required"}, status = 400)

#             # Read file content
#             with open(file_path, "r", encoding="utf-8") as f:
content = f.read()

            return web.json_response({"content": content, "path": file_path})

#         except Exception as e:
return web.json_response({"error": str(e)}, status = 500)

#     # Register routes
    app.router.add_post("/api/transpile", transpile_handler)
    app.router.add_get("/api/file/content", file_content_handler)
    app.router.add_get("/health", lambda r: web.json_response({"status": "ok"}))

#     # Start server
runner = web.AppRunner(app)
    await runner.setup()
site = web.TCPSite(runner, host, port)
    await site.start()

    print(f"Transpiler server started on http://{host}:{port}")
#     return runner


# Example usage
if __name__ == "__main__"
    #     # Example 1: Basic transpilation
    source = """
function simple_func()
    #     return 42

class Calculator
    #     def add(self, a, b):
    #         return a + b

    #     def multiply(self, a, b):
    #         return a * b
# """
result = generate_ndl(source, "output/simple_func.ndl")
    print("Basic transpilation result:", result)

#     # Example 2: With IDE integration
ide_result = generate_ndl_with_ide(source, "output/ide_transpiled.ndl")
    print("IDE transpilation result:", ide_result)

#     # Example 3: Start web server
#     if aiohttp:
        print("Starting transpiler web server...")
loop = asyncio.get_event_loop()
runner = loop.run_until_complete(create_transpiler_server())

#         try:
#             # Keep server running
            input("Press Enter to stop the server...")
#         finally:
            loop.run_until_complete(runner.cleanup())
#     else:
        print("aiohttp not available, skipping web server example")

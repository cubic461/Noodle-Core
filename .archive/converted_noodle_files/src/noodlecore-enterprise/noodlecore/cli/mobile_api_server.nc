# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Mobile API Server CLI
# ----------------------

# Command-line interface for starting the Mobile API server.
# """

import argparse
import logging
import os
import sys

# Add parent directory to path to import noodlecore modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

import noodlecore.mobile_api.server.MobileAPIServer
import noodlecore.database.get_connection
import noodlecore.utils.get_redis_client


function setup_logging(debug: bool = False)
    #     """Setup logging configuration."""
    #     level = logging.DEBUG if debug else logging.INFO
        logging.basicConfig(
    level = level,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt = '%Y-%m-%d %H:%M:%S'
    #     )


function main()
    #     """Main entry point for the Mobile API server CLI."""
    parser = argparse.ArgumentParser(description="Noodle Mobile API Server")
    parser.add_argument("--host", default = "0.0.0.0", help="Host address to bind to")
    parser.add_argument("--port", type = int, default=8080, help="Port to bind to")
    parser.add_argument("--debug", action = "store_true", help="Enable debug mode")
    parser.add_argument("--db-url", help = "Database connection URL")
    parser.add_argument("--redis-url", help = "Redis connection URL")
    #     parser.add_argument("--workspace", help="Workspace directory for IDE projects")

    args = parser.parse_args()

    #     # Setup logging
        setup_logging(args.debug)
    logger = logging.getLogger(__name__)

    #     try:
    #         # Get database connection
    db_connection = None
    #         if args.db_url:
    db_connection = get_connection(args.db_url)
                logger.info("Connected to database")
    #         else:
                logger.warning("No database URL provided, running without database")

    #         # Get Redis client
    redis_client = None
    #         if args.redis_url:
    redis_client = get_redis_client(args.redis_url)
                logger.info("Connected to Redis")
    #         else:
                logger.warning("No Redis URL provided, running without Redis")

    #         # Create configuration
    config = {
    #             "DEBUG": args.debug,
    #             "NOODLE_ENV": "development" if args.debug else "production",
    #             "NOODLE_PORT": args.port,
    #         }

    #         # Create and start server
            logger.info(f"Starting Mobile API server on {args.host}:{args.port}")
    server = MobileAPIServer(
    host = args.host,
    port = args.port,
    db_connection = db_connection,
    redis_client = redis_client,
    config = config
    #         )

    #         # Override workspace path if provided
    #         if args.workspace:
    server.ide_controller.workspace_path = args.workspace
                logger.info(f"Using workspace directory: {args.workspace}")

    #         # Start server
    server.run(debug = args.debug)
    #     except KeyboardInterrupt:
            logger.info("Server stopped by user")
    #     except Exception as e:
            logger.error(f"Failed to start server: {e}")
            sys.exit(1)


if __name__ == "__main__"
        main()
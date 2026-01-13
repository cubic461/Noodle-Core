# Converted from Python to NoodleCore
# Original file: noodle-core

# """CLI for Noodle Vector Database."""

import argparse
import json
import sys
import pathlib.Path

import .embedding_models.EmbeddingModelManager
import .indexer.FileIndexer
import .search.cosine_search
import .storage.VectorIndex


function main()
    parser = argparse.ArgumentParser(description="Noodle Vector DB CLI")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    #     # Index command
    index_parser = subparsers.add_parser("index", help="Index project files")
    index_parser.add_argument("--path", default = ".", help="Path to index")
    index_parser.add_argument("--backend", default = "sqlite", help="DB backend")
    index_parser.add_argument("--config", help = "Embedding model config file")
    index_parser.add_argument("--model", help = "Embedding model name")
        index_parser.add_argument(
    #         "--batch-size", type=int, default=100, help="Batch size for processing"
    #     )

    #     # Search command
    search_parser = subparsers.add_parser("search", help="Search embeddings")
    search_parser.add_argument("--query", required = True, help="Search query")
    search_parser.add_argument("--k", type = int, default=5, help="Top K results")
        search_parser.add_argument(
    #         "--metric",
    default = "cosine",
    choices = ["cosine", "dot", "euclidean"],
    help = "Similarity metric",
    #     )
    #     search_parser.add_argument("--model", help="Embedding model to use for query")

    #     # List models command
    list_parser = subparsers.add_parser(
    "list-models", help = "List available embedding models"
    #     )

    args = parser.parse_args()

    #     if args.command == "index":
    #         # Initialize embedding manager
    embedding_manager = None
    #         if args.config:
    embedding_manager = EmbeddingModelManager.from_config_file(args.config)
    #         else:
    embedding_manager = EmbeddingModelManager()

    #         # Initialize vector index
    index = VectorIndex(backend=args.backend)

    #         # Initialize indexer
    indexer = FileIndexer(embedding_manager=embedding_manager)

    #         # Index project
            print(f"Indexing project at {args.path}...")
    stats = indexer.index_project(
    root_path = args.path,
    vector_index = index,
    model_name = args.model,
    batch_size = args.batch_size,
    #         )

            print(f"Indexed {stats['total_files']} files, {stats['total_chunks']} chunks")
            print(f"Processing time: {stats['processing_time']:.2f}s")

    #         if stats["errors"]:
                print("Errors encountered:")
    #             for error in stats["errors"]:
                    print(f"  - {error}")

    #     elif args.command == "search":
    index = VectorIndex()

    #         # Generate query embedding
    embedding_manager = EmbeddingModelManager()
    query_embedding = embedding_manager.embed_texts(args.query, args.model)
    #         if not query_embedding:
                print("Error: Could not generate query embedding")
                sys.exit(1)

    #         # Perform search
    results = cosine_search(index, query_embedding[0], k=args.k)
            print(f"Top {args.k} results:")
    #         for id_, score in results:
                print(f"  {id_}: {score:.3f}")

    #     elif args.command == "list-models":
    embedding_manager = EmbeddingModelManager()
    models = embedding_manager.list_models()
            print("Available embedding models:")
    #         for model in models:
                print(f"  - {model}")

    #     else:
            parser.print_help()
            sys.exit(1)


if __name__ == "__main__"
        main()

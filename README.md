# simple-naive-ollama-benchmark

Very simple script for getting startup time/tokens per second from an ollama instance.

This does nothing to reflect how many models might be run in parallel and takes no account of the amount of RAM available on the GPUs. A GPU might be far more capable that this makes it appear if it has a lot of RAM but is slower. For instance, a Thor or Spark can run much larger models than an RTX 3090 though the RTX 3090 will be faster for the models it can run.

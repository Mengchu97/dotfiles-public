---
name: deep-learning
description: Best practices and patterns for PyTorch deep learning code, including training loops, model definitions, data pipelines, GPU management, distributed training, and experiment tracking.
---

## What I do

- Write PyTorch training loops with proper device handling, mixed precision (AMP), gradient clipping
- Design model architectures (CNN, Transformer, GNN) following current best practices
- Set up data loaders with proper batching, shuffling, and augmentation pipelines
- Configure optimizers (AdamW, SGD with momentum), learning rate schedulers (CosineAnnealing, OneCycleLR, ReduceLROnPlateau)
- Integrate experiment tracking (wandb, tensorboard)
- Implement distributed training (DDP, FSDP)
- Handle checkpoint save/load, resume training, early stopping
- Debug CUDA OOM, gradient explosion/vanishing, and numerical instability

## Conventions

- Always use `torch.nn.Module` with type-annotated `__init__` and `forward`
- Use `torch.no_grad()` for inference, `torch.cuda.amp.autocast` for mixed precision
- Prefer `torch.utils.data.Dataset` + `DataLoader` over manual batching
- Use `configurable` training configs (dataclass or argparse), never hardcode hyperparameters
- Log training metrics at every epoch, validation metrics at configurable intervals
- Use `torch.compile` when PyTorch >= 2.0 for performance

## When to use me

Use this skill when writing or debugging deep learning training code, model definitions, data pipelines, GPU-related issues, or experiment configurations.

Ask clarifying questions if:
- The target framework is unclear (PyTorch vs JAX vs TensorFlow)
- The hardware setup is unspecified (single GPU vs multi-GPU vs TPU)
- The deployment target matters (research prototype vs production)

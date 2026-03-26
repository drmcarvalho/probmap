# ProbMap

An application that uses the problem definition approach by Professor Jorge Muniz Barreto, described in *"Introdução às Redes Neurais Artificiais"* (Introduction to Artificial Neural Networks). It follows the format **P = (I, B, C)** for modeling, mapping, and formalizing problems in general.

## The Formula

| Symbol | Meaning |
|--------|---------|
| **P** | The problem itself |
| **B** | The dataset of the problem |
| **I** | The set of operations, transformations, and results |
| **C** | The condition — a binary relation that satisfies the problem |

Reference: [Teoria dos Problemas – Wikipedia (PT)](https://pt.wikipedia.org/wiki/Teoria_dos_problemas)

## Usage / Getting Started

### Prerequisites

- [Elixir](https://elixir-lang.org/install.html) >= 1.17.3
- [Phoenix Framework](https://www.phoenixframework.org/) >= v1.8.5

### Setup

```bash
# Clone the repository
git clone https://github.com/drmcarvalho/probmap.git
cd probmap
```
# Start

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

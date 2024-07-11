A pdf generator for CVs using typst

<img src="docs/example.png" alt="Example generated pdf"/>

## Usage

```bash
# Create `cv.pdf` in working directory
nix run github:morrisfeist/cvgen -- path/to/input.json

# Create PDF file at the desired path
nix run github:morrisfeist/cvgen -- path/to/input.json path/to/output.pdf
```
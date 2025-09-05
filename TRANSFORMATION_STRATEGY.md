# Jebasa Transformation Strategy: From Shell Scripts to Modern Python Package

## Executive Summary

This document outlines the comprehensive transformation strategy for converting the current Japanese audio-text alignment pipeline from a collection of shell scripts into a modern, professional open-source Python package. The transformation will create a maintainable, extensible, and user-friendly tool that follows Python best practices and modern development standards.

## Current State Analysis

### Project Structure
The current pipeline consists of:
- **5 shell scripts** (`1_prepare_audio_v3.sh` through `5_create_srt_v3.sh`)
- **5 Python modules** in `/scripts/` directory
- **Hard-coded configuration** scattered across scripts
- **Manual workflow** requiring user intervention at multiple steps
- **No package structure** or dependency management

### Key Dependencies
- **Montreal Forced Aligner (MFA)** - Core alignment engine
- **FFmpeg** - Audio processing
- **fugashi** - Japanese morphological analysis
- **BeautifulSoup4** - HTML/XML parsing
- **Standard Unix tools** (find, awk, perl, etc.)

### Current Workflow
1. **Audio Preparation**: Merge multi-part audio files, convert to WAV
2. **Text Preparation**: Extract and validate chapters from EPUB/XHTML
3. **Dictionary Creation**: Generate custom pronunciation dictionary
4. **Alignment**: Run MFA alignment on processed corpus
5. **SRT Generation**: Convert alignment output to subtitle files

## Transformation Strategy

### 1. Modern Python Package Structure

```
jebasa/
├── pyproject.toml              # Modern Python packaging
├── README.md                   # Project documentation
├── LICENSE                     # MIT or Apache 2.0
├── CHANGELOG.md               # Version history
├── .gitignore                 # Git ignore patterns
├── .github/
│   └── workflows/
│       ├── ci.yml             # Continuous integration
│       └── release.yml        # Automated releases
├── src/
│   └── jebasa/
│       ├── __init__.py
│       ├── __main__.py        # CLI entry point
│       ├── cli.py             # Command-line interface
│       ├── config.py          # Configuration management
│       ├── core/
│       │   ├── __init__.py
│       │   ├── audio.py       # Audio processing
│       │   ├── text.py        # Text processing
│       │   ├── dictionary.py  # Dictionary management
│       │   ├── alignment.py   # MFA alignment wrapper
│       │   └── subtitles.py   # SRT generation
│       ├── utils/
│       │   ├── __init__.py
│       │   ├── logging.py     # Logging configuration
│       │   ├── validation.py  # Input validation
│       │   └── helpers.py     # Utility functions
│       └── models/
│           ├── __init__.py
│           └── data_models.py # Data structures
├── tests/
│   ├── __init__.py
│   ├── conftest.py            # Pytest configuration
│   ├── test_audio.py
│   ├── test_text.py
│   ├── test_dictionary.py
│   ├── test_alignment.py
│   └── test_subtitles.py
├── docs/
│   ├── index.md               # Documentation homepage
│   ├── installation.md        # Installation guide
│   ├── usage.md               # Usage examples
│   ├── api.md                 # API reference
│   └── contributing.md        # Contribution guidelines
├── examples/
│   ├── basic_usage.py         # Basic usage example
│   ├── advanced_config.py     # Advanced configuration
│   └── custom_pipeline.py     # Custom pipeline example
└── data/
    ├── dictionaries/          # Default dictionaries
    └── models/               # Default models
```

### 2. Configuration Management System

#### Configuration Hierarchy
```python
# jebasa/config.py
from pathlib import Path
from typing import Dict, Any, Optional
from pydantic import BaseModel, Field
from enum import Enum

class AudioFormat(str, Enum):
    MP3 = "mp3"
    WAV = "wav"
    M4A = "m4a"

class TextFormat(str, Enum):
    EPUB = "epub"
    XHTML = "xhtml"

class AlignmentConfig(BaseModel):
    beam: int = Field(default=100, ge=10, le=1000)
    retry_beam: int = Field(default=400, ge=100, le=2000)
    num_jobs: int = Field(default=4, ge=1, le=32)
    clean: bool = Field(default=True)
    single_speaker: bool = Field(default=True)

class AudioConfig(BaseModel):
    sample_rate: int = Field(default=16000, ge=8000, le=48000)
    channels: int = Field(default=1, ge=1, le=2)
    codec: str = Field(default="pcm_s16le")
    format: AudioFormat = Field(default=AudioFormat.MP3)

class TextConfig(BaseModel):
    format: TextFormat = Field(default=TextFormat.XHTML)
    min_paragraphs: int = Field(default=5, ge=1)
    min_characters: int = Field(default=200, ge=50)
    blacklist_keywords: list[str] = Field(default_factory=lambda: [
        "奥付", "発行", "印刷", "製本", "著作権", "配信",
        "Copyright", "All rights reserved", "Publisher"
    ])

class JebasaConfig(BaseModel):
    """Main configuration class for Jebasa"""
    audio: AudioConfig = Field(default_factory=AudioConfig)
    text: TextConfig = Field(default_factory=TextConfig)
    alignment: AlignmentConfig = Field(default_factory=AlignmentConfig)
    
    # Paths configuration
    input_dir: Path = Field(default=Path("input"))
    output_dir: Path = Field(default=Path("output"))
    temp_dir: Path = Field(default=Path("temp"))
    
    # MFA configuration
    mfa_model: str = Field(default="japanese_mfa")
    custom_dictionary_path: Optional[Path] = None
    
    # Logging
    log_level: str = Field(default="INFO")
    verbose: bool = Field(default=False)
```

#### Configuration Sources (Priority Order)
1. **Command-line arguments** (highest priority)
2. **Configuration file** (`jebasa.toml` or `jebasa.yaml`)
3. **Environment variables** (`JEBASA_*`)
4. **Default values** (lowest priority)

#### Configuration File Example
```toml
# jebasa.toml
[audio]
sample_rate = 16000
channels = 1
format = "mp3"

[text]
format = "xhtml"
min_paragraphs = 5
min_characters = 200
blacklist_keywords = ["奥付", "発行", "著作権"]

[alignment]
beam = 100
retry_beam = 400
num_jobs = 4
clean = true

[paths]
input_dir = "input"
output_dir = "output"
temp_dir = "temp"

[mfa]
model = "japanese_mfa"
custom_dictionary = "custom.dict"
```

### 3. CLI Design Strategy

#### Command Structure
```bash
# Main command groups
jebasa audio prepare [OPTIONS] INPUT_DIR
jebasa text prepare [OPTIONS] INPUT_FILE
jebasa dictionary create [OPTIONS] TEXT_DIR
jebasa align [OPTIONS] CORPUS_DIR
jebasa subtitles create [OPTIONS] ALIGNMENT_DIR

# Pipeline commands
jebasa pipeline run [OPTIONS] --audio-dir AUDIO_DIR --text-dir TEXT_DIR
jebasa pipeline validate [OPTIONS] CONFIG_FILE

# Utility commands
jebasa config init [OPTIONS]
jebasa config validate [OPTIONS]
jebasa info [OPTIONS]
```

#### CLI Features
- **Progress bars** for long-running operations
- **Colored output** for better readability
- **Dry-run mode** for testing configurations
- **Parallel processing** with configurable workers
- **Resume capability** for interrupted workflows
- **Detailed logging** with multiple verbosity levels

### 4. Modern Python Tooling Integration

#### Development Tools
```toml
# pyproject.toml - Development dependencies
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "jebasa"
dynamic = ["version"]
description = "Japanese audio-text alignment pipeline"
readme = "README.md"
license = "MIT"
authors = [
    {name = "Your Name", email = "your.email@example.com"},
]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "Intended Audience :: Science/Research",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Topic :: Multimedia :: Sound/Audio :: Analysis",
    "Topic :: Text Processing :: Linguistic",
]
dependencies = [
    "click>=8.0.0",
    "pydantic>=2.0.0",
    "rich>=13.0.0",
    "tqdm>=4.64.0",
    "beautifulsoup4>=4.11.0",
    "fugashi>=1.2.0",
    "pydantic-settings>=2.0.0",
    "pathlib2>=2.3.0;python_version<'3.4'",
]
requires-python = ">=3.8"

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pytest-mock>=3.10.0",
    "black>=23.0.0",
    "isort>=5.12.0",
    "flake8>=6.0.0",
    "mypy>=1.0.0",
    "pre-commit>=3.0.0",
    "sphinx>=6.0.0",
    "sphinx-rtd-theme>=1.2.0",
]
test = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pytest-mock>=3.10.0",
    "responses>=0.23.0",
]

[project.scripts]
jebasa = "jebasa.cli:main"

[project.urls]
Homepage = "https://github.com/yourusername/jebasa"
Documentation = "https://jebasa.readthedocs.io"
Repository = "https://github.com/yourusername/jebasa"
Issues = "https://github.com/yourusername/jebasa/issues"

[tool.hatch.version]
path = "src/jebasa/__init__.py"

[tool.hatch.build.targets.sdist]
include = [
    "/src",
    "/tests",
    "/docs",
    "/examples",
]

[tool.black]
line-length = 88
target-version = ['py38']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88
known_first_party = ["jebasa"]

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra -q --strict-markers --strict-config"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
]

[tool.coverage.run]
source = ["src/jebasa"]
omit = ["*/tests/*", "*/test_*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if self.debug:",
    "if settings.DEBUG",
    "raise AssertionError",
    "raise NotImplementedError",
    "if 0:",
    "if __name__ == .__main__.:",
    "class .*\\bProtocol\\):",
    "@(abc\\.)?abstractmethod",
]
```

#### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-case-conflict
      - id: check-merge-conflict
      - id: check-json
      - id: check-toml
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        additional_dependencies: [flake8-docstrings]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.5.1
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
        args: [--ignore-missing-imports]
```

### 5. Dependency Management Strategy

#### Core Dependencies
```python
# Runtime dependencies
"click>=8.0.0",          # CLI framework
"pydantic>=2.0.0",       # Data validation and settings
"rich>=13.0.0",          # Rich text and beautiful formatting
"tqdm>=4.64.0",          # Progress bars
"beautifulsoup4>=4.11.0", # HTML/XML parsing
"fugashi>=1.2.0",        # Japanese morphological analysis
"pydantic-settings>=2.0.0", # Settings management
```

#### External Tool Dependencies
- **Montreal Forced Aligner**: System dependency with Python API
- **FFmpeg**: System dependency for audio processing
- **MeCab**: System dependency for Japanese text processing

#### Dependency Installation Strategy
```bash
# Install with system dependencies
pip install jebasa[full]

# Install core only (user provides external tools)
pip install jebasa

# Development installation
git clone https://github.com/yourusername/jebasa
cd jebasa
pip install -e ".[dev]"
```

### 6. Testing Strategy

#### Test Structure
```python
# tests/conftest.py
import pytest
from pathlib import Path
from jebasa.config import JebasaConfig

@pytest.fixture
def test_data_dir():
    return Path(__file__).parent / "data"

@pytest.fixture
def sample_config():
    return JebasaConfig(
        input_dir="tests/data/input",
        output_dir="tests/data/output",
        temp_dir="tests/data/temp"
    )

@pytest.fixture
def mock_audio_file(tmp_path):
    audio_file = tmp_path / "test.wav"
    # Create minimal WAV file for testing
    audio_file.write_bytes(b"mock_wav_data")
    return audio_file
```

#### Test Categories
1. **Unit Tests**: Individual function testing
2. **Integration Tests**: Component interaction testing
3. **End-to-End Tests**: Full pipeline testing
4. **Performance Tests**: Large dataset handling
5. **Error Handling Tests**: Edge cases and failures

### 7. Documentation Structure

#### Documentation Types
1. **User Documentation**: Installation, usage, examples
2. **API Documentation**: Auto-generated from docstrings
3. **Developer Documentation**: Architecture, contributing
4. **Tutorial Documentation**: Step-by-step guides

#### Documentation Tools
- **Sphinx**: Documentation generation
- **MyST**: Markdown support for Sphinx
- **Read the Docs**: Hosting platform
- **Jupyter Notebooks**: Interactive examples

### 8. CI/CD Pipeline

#### GitHub Actions Workflow
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ["3.8", "3.9", "3.10", "3.11"]

    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install system dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y ffmpeg mecab libmecab-dev
    
    - name: Install Python dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -e ".[dev]"
    
    - name: Run pre-commit hooks
      run: |
        pre-commit run --all-files
    
    - name: Run tests
      run: |
        pytest --cov=jebasa --cov-report=xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella
```

### 9. Migration Strategy

#### Phase 1: Foundation (Week 1-2)
- Set up package structure and development environment
- Implement configuration management system
- Create basic CLI framework
- Set up testing infrastructure

#### Phase 2: Core Components (Week 3-4)
- Port audio processing functionality
- Port text processing functionality
- Port dictionary creation functionality
- Implement comprehensive testing

#### Phase 3: Integration (Week 5-6)
- Port alignment functionality
- Port subtitle generation functionality
- Implement pipeline orchestration
- Add end-to-end testing

#### Phase 4: Polish & Release (Week 7-8)
- Add comprehensive documentation
- Implement advanced CLI features
- Performance optimization
- Community feedback and iteration

### 10. Key Transformation Requirements

#### Shell Script to Python CLI Conversion
- **Maintain functionality**: All existing features must be preserved
- **Improve usability**: Add progress bars, better error messages, logging
- **Enhance configurability**: Replace hard-coded values with configurable options
- **Add validation**: Input validation and error checking
- **Enable automation**: Remove manual intervention steps

#### Configuration Management
- **Centralized configuration**: Single source of truth for all settings
- **Multiple formats**: Support TOML, YAML, JSON, environment variables
- **Validation**: Type checking and validation of all configuration values
- **Documentation**: Auto-generated configuration documentation
- **Migration**: Tools to migrate from shell script configurations

#### Modern Python Tooling
- **Type hints**: Full type annotation coverage
- **Code formatting**: Consistent formatting with Black and isort
- **Linting**: Code quality enforcement with flake8 and mypy
- **Testing**: Comprehensive test coverage with pytest
- **Documentation**: Auto-generated API documentation

#### Dependency Management
- **Explicit dependencies**: All dependencies declared in pyproject.toml
- **Version pinning**: Compatible version ranges for reproducible builds
- **Optional dependencies**: Optional features with extras_require
- **System dependencies**: Clear documentation of external tool requirements

#### Documentation Structure
- **User guides**: Step-by-step tutorials for common use cases
- **API reference**: Complete API documentation with examples
- **Configuration guide**: Detailed configuration options and examples
- **Migration guide**: Instructions for migrating from shell scripts
- **Contributing guide**: Guidelines for contributors

## Implementation Roadmap

### Week 1-2: Foundation
- [ ] Set up package structure with pyproject.toml
- [ ] Implement configuration management with Pydantic
- [ ] Create basic CLI framework with Click
- [ ] Set up development environment with pre-commit hooks
- [ ] Implement logging and error handling

### Week 3-4: Core Components
- [ ] Port audio processing (ffmpeg wrapper, format conversion)
- [ ] Port text processing (EPUB/XHTML parsing, validation)
- [ ] Port dictionary creation (furigana extraction, IPA conversion)
- [ ] Implement comprehensive unit tests
- [ ] Add progress bars and user feedback

### Week 5-6: Integration
- [ ] Port MFA alignment wrapper
- [ ] Port subtitle generation (TextGrid to SRT conversion)
- [ ] Implement pipeline orchestration
- [ ] Add end-to-end integration tests
- [ ] Implement parallel processing

### Week 7-8: Polish & Release
- [ ] Write comprehensive documentation
- [ ] Add advanced CLI features (dry-run, resume, validation)
- [ ] Performance optimization and profiling
- [ ] Create examples and tutorials
- [ ] Community feedback and iteration

## Success Metrics

### Technical Metrics
- **Test coverage**: >90% code coverage
- **Type coverage**: 100% type annotation coverage
- **Documentation**: 100% public API documented
- **Performance**: No significant performance regression
- **Compatibility**: Support for Python 3.8+

### User Experience Metrics
- **Installation time**: <5 minutes for new users
- **First-run success**: >95% success rate for basic usage
- **Error clarity**: All errors provide actionable guidance
- **Documentation**: Complete migration guide from shell scripts
- **Community**: Active issue resolution and feature requests

### Maintenance Metrics
- **Code quality**: Consistent formatting and linting
- **Dependency updates**: Regular automated dependency updates
- **Security**: No known security vulnerabilities
- **Releases**: Regular release schedule with semantic versioning
- **Community**: Growing contributor base and user adoption

## Risk Assessment and Mitigation

### Technical Risks
1. **MFA dependency**: External tool dependency could break
   - **Mitigation**: Version pinning, compatibility testing, fallback options

2. **Performance regression**: Python might be slower than shell scripts
   - **Mitigation**: Profiling, optimization, parallel processing

3. **Complexity increase**: Modern tooling might be overwhelming
   - **Mitigation**: Gradual adoption, clear documentation, community support

### Project Risks
1. **Community adoption**: Users might resist change
   - **Mitigation**: Clear migration path, feature parity, community engagement

2. **Maintenance burden**: Increased complexity could burden maintainers
   - **Mitigation**: Automated tooling, clear contribution guidelines, community involvement

3. **Feature creep**: Scope might expand beyond original intent
   - **Mitigation**: Clear project scope, focused development, community feedback

## Conclusion

This transformation strategy provides a comprehensive roadmap for converting the Jebasa Japanese audio-text alignment pipeline from shell scripts to a modern Python package. The strategy maintains backward compatibility while adding significant value through improved usability, maintainability, and extensibility.

The phased approach ensures steady progress with measurable milestones, while the comprehensive testing and documentation strategy ensures a high-quality final product. The modern Python tooling and best practices will make the project more accessible to contributors and users alike.

By following this strategy, Jebasa will become a professional, maintainable, and user-friendly open-source project that can serve the Japanese language learning and research communities for years to come.
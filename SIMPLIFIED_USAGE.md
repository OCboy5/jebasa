# Jebasa Simplified Usage Guide

The jebasa CLI has been redesigned to use configuration files for path management, making commands much simpler and more intuitive.

## Before (Complex Usage)

```bash
# Run complete pipeline with many arguments
jebasa run --input-dir ./my_book --output-dir ./output

# Or run individual stages with explicit paths
jebasa prepare-audio --input-dir ./my_book/audio --output-dir ./processed
jebasa prepare-text --input-dir ./my_book/text --output-dir ./processed  
jebasa create-dictionary --input-dir ./processed --output-dir ./dictionaries
jebasa align --corpus-dir ./processed --dictionary ./dictionaries/custom.dict --output-dir ./aligned
jebasa generate-subtitles --alignment-dir ./aligned --text-dir ./processed --output-dir ./subtitles
```

## After (Simplified Usage)

```bash
# Configure paths once in jebasa.yaml
# Then run simple commands:

# Run complete pipeline
jebasa run

# Or run individual stages
jebasa prepare-audio
jebasa prepare-text
jebasa create-dictionary  
jebasa align
jebasa generate-subtitles
```

## Configuration File

Create a `jebasa.yaml` file in your project directory:

```yaml
# Path configuration - this is the key to simplicity
paths:
  input_dir: "./my_book"              # Your input files
  output_dir: "./output"              # All output organized here
  temp_dir: "./temp"                  # Temporary files
  
  # Stage-specific directories (auto-created)
  audio_dir: "processed/audio"        # Prepared audio files
  text_dir: "processed/text"          # Processed text files
  dictionary_dir: "dictionaries"      # Pronunciation dictionaries
  alignment_dir: "aligned"            # MFA alignment results
  subtitle_dir: "subtitles"           # Final SRT files

# All your other settings (same as before)
audio:
  sample_rate: 16000
  channels: 1
  format: "wav"

text:
  tokenizer: "mecab"
  extract_furigana: true

mfa:
  acoustic_model: "japanese_mfa"
  beam: 100
  retry_beam: 400

subtitles:
  max_line_length: 42
  max_lines: 2
```

## Usage Examples

### 1. Basic Usage (Recommended)

```bash
# Use configuration file
jebasa -c jebasa.yaml run

# Or put config in default location (./jebasa.yaml)
jebasa run
```

### 2. Override Specific Paths (When Needed)

```bash
# Override input directory for one command
jebasa -c jebasa.yaml prepare-audio --input-dir ./different_audio

# Override output directory
jebasa -c jebasa.yaml align --output-dir ./custom_alignment

# Use custom stage directory
jebasa -c jebasa.yaml align --stage-dir ./my_custom_alignment
```

### 3. Override Settings (Not Paths)

```bash
# Change audio format
jebasa prepare-audio --audio-format mp3

# Change number of alignment jobs
jebasa align --num-jobs 8

# Disable furigana extraction
jebasa prepare-text --no-extract-furigana
```

## Key Features

### Smart Path Resolution
- Commands automatically find input files in expected locations
- Output goes to configured stage directories
- Auto-detection of dictionary files for alignment
- Auto-detection of alignment files for subtitle generation

### Stage-Specific Directories
Each pipeline stage has its own directory:
- **Audio**: `processed/audio/` - Prepared audio files
- **Text**: `processed/text/` - Processed text files  
- **Dictionary**: `dictionaries/` - Pronunciation dictionaries
- **Alignment**: `aligned/` - MFA alignment results
- **Subtitles**: `subtitles/` - Final SRT files

### Flexible Configuration
- Use relative paths (resolved from output_dir)
- Use absolute paths for external locations
- Override any setting via command line
- Mix configuration with command-line overrides

## Migration from Old Usage

### Old Way (Still Works)
```bash
jebasa prepare-audio --input-dir ./input/audio --output-dir ./processed
jebasa prepare-text --input-dir ./input/text --output-dir ./processed
jebasa create-dictionary --input-dir ./processed --output-dir ./dictionaries
jebasa align --corpus-dir ./processed --dictionary ./dictionaries/custom.dict --output-dir ./aligned
jebasa generate-subtitles --alignment-dir ./aligned --text-dir ./processed --output-dir ./subtitles
```

### New Way (Recommended)
```bash
# Configure once in jebasa.yaml
jebasa prepare-audio
jebasa prepare-text
jebasa create-dictionary
jebasa align
jebasa generate-subtitles
```

## Benefits

1. **Simplicity**: No need to remember complex path arguments
2. **Consistency**: Same paths used across all commands
3. **Reproducibility**: Configuration file documents your setup
4. **Flexibility**: Override when needed, use defaults normally
5. **Organization**: Automatic directory structure

## Best Practices

1. **Create a project-specific configuration file**
2. **Commit the configuration to version control**
3. **Use relative paths for portability**
4. **Override paths only when necessary**
5. **Document any non-standard path configurations**

The new system maintains full backward compatibility while providing a much simpler interface for typical usage patterns. You can still use all the old command-line arguments when you need explicit control, but for most cases, the configuration file approach will be much more convenient.
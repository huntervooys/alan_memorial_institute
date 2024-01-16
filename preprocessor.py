import re
import yaml
from pathlib import Path
import glob
import spacy

nlp = spacy.load("en_core_web_sm")

corpus_dir = Path('data') 
document_paths = glob.glob(str(corpus_dir / '*.txt')) 

def load_file(path):
    try:
        with open(path, 'r') as file:
            return file.read()
    except IOError as e:
        print(f"Error opening file {path}: {e}")
        return None

def parse_yaml(data):
    try:
        yaml_header = re.search(r'---\n(.*?)\n---', data, re.DOTALL)
        return yaml.safe_load(yaml_header.group(1))
    except yaml.YAMLError as e:
        print(f"Error parsing YAML frontmatter: {e}")
        return None

def process_document(file_paths):
    corpus = dict()
    yaml_pattern = re.compile(r'---\n(.*?)\n---', re.DOTALL)
    
    # Use a generator to process one file at a time
    def file_generator(file_paths):
        for path in file_paths:
            data = load_file(path)
            if data is not None:
                yield data

    # Use Spacy's nlp.pipe method to process texts as a stream
    for data, doc in zip(file_generator(file_paths), nlp.pipe((text for text in file_generator(file_paths)))):
        metadata = parse_yaml(data)
        if metadata is None:
            continue

        text_without_yaml = yaml_pattern.sub('', data)
        tokens = [token.text.lower() for token in doc if not token.is_punct and not token.is_space]
    
        document = dict(metadata=metadata, nlp_doc=doc, tokens=tokens)
        corpus[metadata['title']] = document
    
    return corpus
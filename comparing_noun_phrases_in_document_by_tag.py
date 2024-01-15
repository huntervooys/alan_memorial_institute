import re
import yaml
from pathlib import Path
from spacy.tokens import Doc
from collections import Counter
import spacy

nlp = spacy.load("en_core_web_sm")


def read_documents(doc_dir):
    """
    Read the documents from the documents directory.
    Store the yaml metadata in a dictionary called metadata.
    Store the text of the document (excluding the YAML frontmatter) in a variable called text.
    Create a corpus with the metadata and a spaCy Doc object for each document.

    Parameters:
    - doc_dir (Path): The directory containing the documents.

    Returns:
    - corpus (list): A list of dictionaries, where each dictionary contains the metadata and text of a document.
    """
    corpus = []

    for doc in doc_dir.iterdir():
        if doc.suffix == ".txt":
            print(f"Processing {doc}")
            with doc.open() as f:
                text = f.read()
            
            # Extract metadata from YAML frontmatter
            yaml_header = re.search(r'---\n(.*?)\n---', text, re.DOTALL)
            metadata = yaml.safe_load(yaml_header.group(1))
            
            # Remove YAML frontmatter from the document text
            text = re.sub(r'---\n(.*?)\n---', '', text, count=1, flags=re.DOTALL)
            
            # Create a dictionary with metadata and text
            document = {
                'metadata': metadata,
                'text': text
            }
            
            # Add the document to the corpus
            corpus.append(document)

            text = re.sub(r'---\n.*?\n---', '', text, flags=re.DOTALL)
            
            doc = nlp(text)
            corpus.append({'metadata': metadata, 'text': doc})

    return corpus

def split_corpus(corpus, tag):
    """
    Split the corpus into two corpuses, one for all documents with the given tag and one for all documents without the given tag.
    """
    corpus_with_tag = [doc for doc in corpus if tag in doc['metadata']['tags']]
    corpus_without_tag = [doc for doc in corpus if tag not in doc['metadata']['tags']]

    return corpus_with_tag, corpus_without_tag

def count_noun_phrases(corpus):
    """
    Count the noun phrases in each document in the corpus.
    """
    noun_phrases = Counter()

    for doc in corpus:
        noun_phrases.update(np.text for np in doc['text'].noun_chunks)

    return noun_phrases

def compare_noun_phrases(corpus_with_tag, corpus_without_tag):
    """
    Compare the noun phrases in the two corpuses by calculating the log likelihood ratio of each noun phrase appearing in the corpus with the tag vs. the corpus without the tag.
    """
    # This function is left as an exercise for the reader, as it requires a specific statistical method to calculate the log likelihood ratio.
    pass

def main():
    """
    Main function to orchestrate the execution of other functions.
    """
    doc_dir = Path("documents")
    corpus = read_documents(doc_dir)
    corpus_indigenous, corpus_indigenous = split_corpus(corpus, 'indigenous')
    noun_phrases_indigenous = count_noun_phrases(corpus_indigenous)
    noun_phrases_non_indigenous = count_noun_phrases(corpus_non_indigenous)
    compare_noun_phrases(noun_phrases_indigenous, noun_phrases_non_indigenous)

if __name__ == "__main__":
    main()
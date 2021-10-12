# 단어 개수 산출용

import pandas as pd
import nltk as nltk 
import re
import itertools
import glob
from konlpy.tag import Kkma
from konlpy.tag import Hannanum
from konlpy.tag import Okt
from konlpy.tag import Komoran
from konlpy.utils import pprint
nltk.download('averaged_perceptron_tagger')
nltk.download('punkt')
nltk.download('stopwords')
komoran = Komoran()
kkma = Kkma()
hannanum = Hannanum()
okt = Okt()

def cleanText(readData):
 
    #텍스트에 포함되어 있는 특수 문자 제거
 
    text = re.sub('[^A-Za-z0-9]', '', readData)
 
    return text

komoran = Komoran(userdic='userdict.txt')
nltk.download('wordnet')
from nltk.stem import WordNetLemmatizer
from nltk.stem import PorterStemmer

lm = WordNetLemmatizer()
s = PorterStemmer()

def process_us_article():
    target = pd.read_json(#put data)
    target2 = pd.read_json(#put data)
    target2 = pd.concat([target, target2])

    sentences = nltk.sent_tokenize(target2.contents.iloc[1])
    is_noun = lambda pos: pos[:2] == 'NN'
    tokenized = nltk.word_tokenize(str(sentences))
    nouns = [word for (word, pos) in nltk.pos_tag(tokenized) if is_noun(pos)] 

    text = []
    for i in range(0,target2.shape[0]):
        target2.contents.iloc[i] = re.sub('ADVERTISEMENT','',target2.contents.iloc[i])
        target2.contents.iloc[i] = re.sub('Jong Un','JongUn',target2.contents.iloc[i])
        target2.contents.iloc[i] = re.sub('Jong-Un','JongUn',target2.contents.iloc[i])
        target2.contents.iloc[i] = re.sub('jong un','JongUn',target2.contents.iloc[i])
        target2.contents.iloc[i] = re.sub('Jong un','JongUn',target2.contents.iloc[i])
        if 'summit' in target2.contents.iloc[i]:
            texts = nltk.tokenize.sent_tokenize(target2.contents.iloc[i])
            text.append(texts)

    stop_words = set(nltk.corpus.stopwords.words('english'))

    chain_object = itertools.chain.from_iterable(text)
    text = list(chain_object)

    text_sentenced = []
    pre = 0
    noun = 0
    post = 0
    stem = 0

    for texts in text:
        text_sentenced.append(nltk.word_tokenize(texts))
        tokenized = nltk.word_tokenize(str(texts))
        pre = pre + len(tokenized)
        nouns = [word for (word, pos) in nltk.pos_tag(tokenized) if is_noun(pos)]
        text_sentenced.append(nouns)
        noun = noun + len(nouns)



    text_stopped = []
    for keys in text_sentenced:
        key_temp = []
        for w in keys:
            if w not in stop_words:

                if cleanText(w) != "":
                    key_temp.append(cleanText(w))
                    post = post + 1
            key_temp = [s.stem(w) for w in key_temp]
            stem = stem + len(key_temp)
        text_stopped.append(key_temp)
        
    documents = []

    for texts in text_stopped:
        temp = ""
        for items in texts:
            temp = temp + "  " + items
        documents.append(temp)
    
    flat_list = [item for sublist in text_stopped for item in sublist]

    def by_size(words,size):
        result = []
        for word in words:
            if len(word)>=size:
                result.append(word)
        return result

    flat_list = by_size(flat_list,2)

    from collections import Counter

    corpus = documents
    from sklearn.feature_extraction.text import TfidfVectorizer

    tfidfv = TfidfVectorizer(ngram_range=(1, 1)).fit(corpus)
    count = tfidfv.transform(corpus).toarray().sum(axis = 0)

    import matplotlib.pyplot as plt
    import numpy as np

    idx = np.argsort(-count)
    count = count[idx]
    feature_name = np.array(tfidfv.get_feature_names())[idx]
    
    return ([len(target2.contents.dropna()),pre, post, len(text)])

process_us_article_all()
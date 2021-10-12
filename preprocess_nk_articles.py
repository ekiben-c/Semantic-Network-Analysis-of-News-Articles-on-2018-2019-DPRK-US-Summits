import nltk as nltk 
import re
import itertools
import glob
from konlpy.tag import Kkma
from konlpy.tag import Hannanum
from konlpy.tag import Okt
from konlpy.tag import Komoran
from konlpy.utils import pprint
import kss

komoran = Komoran()
kkma = Kkma()
hannanum = Hannanum()
okt = Okt()

def cleanText(readData):
 
    #텍스트에 포함되어 있는 특수 문자 제거
 
    text = re.sub('[^A-Za-z0-9]', '', readData)
 
    return text

komoran = Komoran(userdic='userdict.txt') #put supplied user-dict

temp = pd.read_excel(#put worksheets for analysis,engine='openpyxl')

target_list = []
article_list = []
pre_list = []
post_list = []
len_sentence_list = []

for i in ['1st','2nd','3rd']:
    text = []
    article_no = 0
    for target in target_list:
        for items in glob.glob(#put article worksheets):
            text2 = pd.read_excel(items,engine='openpyxl')
            text2 = list(text2.Contents.dropna())
            matching = [s for s in text2 if "회담" in s]
            text.extend(matching)
            article_no = article_no + len(text)
        stopwords = pd.read_excel(#put custom stop-words ,engine='openpyxl')
        stopwords = list(stopwords.stopwords)

        text_sentenced = []

        import re

        pre = 0
        post = 0
        len_sentence = 0
        
        for texts in text:
            try:
                len_sentence = len_sentence + len(kss.split_sentences(texts))
                targets2 = komoran.pos(texts)
                targets = []
                res = len(re.findall(r'\w+', texts)) 
                pre = pre + len(targets2)
                for items in targets2:

                    if 'N' in items[1]:
                        targets.append(items[0])

            except:
                targets = str(texts)
            targets = [each_word for each_word in targets if each_word not in stopwords]
            post = post + len(targets)
            text_sentenced.append(targets)
            
    documents = []

    for texts in text_sentenced:
        temp = ""
        for items in texts:
            temp = temp + "  " + items
        documents.append(temp)
            
    flat_list = [item for sublist in text_sentenced for item in sublist]

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
    
    pd.DataFrame(list(zip(feature_name, count))).to_csv(output_filename, encoding = 'utf-8-sig')
            
    article_list.append(article_no)
    pre_list.append(pre)
    post_list.append(post)
    len_sentence_list.append(len_sentence)
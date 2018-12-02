    import re
    import numpy as np

    from sklearn.naive_bayes import MultinomialNB
    from sklearn.feature_extraction.text import CountVectorizer
    import pandas as pd
    from collections import Counter
    from sklearn.model_selection import train_test_split
    from sklearn.feature_extraction.text import TfidfTransformer

    import jenkspy
    import matplotlib.pyplot as plt
    plt.style.use('seaborn-poster')

    %matplotlib inline
    import nltk

    from nltk.stem import LancasterStemmer

    def text_preprocessing(food_name):

        # Remove all the special characters

        line = re.sub(r'\\W', ' ', food_name)


        # remove all single characters

        line = re.sub(r'\\s+[a-zA-Z]\\s+', ' ', line)


        # Remove single characters from the start

        line = re.sub(r'\\^[a-zA-Z]\\s+', ' ', line) 


        # Substituting multiple spaces with single space

        line = re.sub(r'\\s+', ' ', line, flags=re.I)


        # Converting to Lowercase

        line = line.lower()

        # Lemmatization

        line = line.split()

        lancaster=LancasterStemmer()

        line = [lancaster.stem(word) for word in line]

        line = ' '.join(line)

        return line

    menu_sentence = "CALIFORNIA CHOPPED KALE. AVOCADO. RED PEPPER. CUCUMBER. PISTACHIO. WHITE BALSAMIC. GF"
    text_preprocessing(menu_sentence)
    df = pd.read_excel("data/supertrackerfooddatabase.xlsx", sheet_name="Nutrients")
    del df["Action"]
    df.columns
    feature = '_269 Sugars, total (g)'
    df.describe()['_269 Sugars, total (g)']
    df.describe()['_205 Carbohydrate (g)']
    nutrients_df = df.dropna()

    nutrients_df['foodname'] = nutrients_df.apply(lambda row: text_preprocessing(row['foodname']), axis=1)
    nutrients_df['foodname']
    foodname_list = nutrients_df['foodname'].tolist()

    feature_list = pd.cut(nutrients_df[feature], breaks, labels=breaks[1:], right=True, include_lowest=True)

    buckets = {i: idx for idx, i in enumerate(breaks)}

    feature_list = [buckets[i] for i in feature_list]

    feature_list = np.array(feature_list)


    count_vect = CountVectorizer()

    x_train_counts = count_vect.fit_transform(foodname_list)


    tfidf_transformer = TfidfTransformer()

    x_train_tfidf = tfidf_transformer.fit_transform(x_train_counts)


    train_x, test_x, train_y, test_y = train_test_split(x_train_tfidf, feature_list, test_size=0.3)


    clf = MultinomialNB().fit(train_x, train_y)

    y_score = clf.predict(test_x)


    n_right = 0

    for i in range(len(y_score)):

        if y_score[i] == test_y[i]:

            n_right += 1


    print("Accuracy: %.2f%%" % ((n_right/float(len(test_y)) * 100)))
    to_test = ["Bacon Ranch Grilled Chicken Salad Artisan grilled chicken", "Real fruit for a real treat. Fruit 'N Yogurt Parfait Creamy Fruit ‘N Yogurt Parfait with low-fat vanilla yogurt, layers of plump blueberries and sweet strawberries, and a crunchy granola topping",

              "Coca-Cola"]

    x_train_counts = count_vect.transform(to_test)


    x_train_tfidf = tfidf_transformer.transform(x_train_counts)

    y_score = clf.predict(x_train_tfidf)

    y_score
    def get_breaks_jenks(array, nb_class=5):

        breaks = jenkspy.jenks_breaks(array, nb_class)

        return breaks

    breaks = get_breaks_jenks(nutrients_df[feature])

    plt.figure(figsize = (10,8))

    hist = plt.hist(nutrients_df[feature], bins='auto', align='left', color='g')

    for b in breaks:

        plt.vlines(b, ymin=0, ymax = max(hist[0]))
    breaks
    labels = ['0.0 - 7.0899',

     '7.0899 - 19.57',

     '19.57 - 35.59',

     '35.59 - 44.59',

     '44.59 - 99.7998']
    def get_breaks(data, classes):

        sum_vals = sum(data)

        elements_per_interval = int(len(data)/classes)

        data = sorted(data)

        breaks = []

        for i, val in enumerate(data):

            if (i + 1) % elements_per_interval == 0:

                breaks.append(val)

        return breaks
    breaks = get_breaks(data, 5)
    plt.figure(figsize = (10,8))

    hist = plt.hist(data, bins='auto', align='left', color='g')

    for b in breaks:

        plt.vlines(b, ymin=0, ymax = max(hist[0]))

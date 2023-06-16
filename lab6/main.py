import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.model_selection import cross_val_score

df = pd.read_csv('dataset/titanic.csv', decimal='.')
df.fillna(df.mean(numeric_only=True), inplace=True)

gender_map = {'female': 0, 'male': 1}
df.Sex = df.Sex.replace(gender_map)

train, test = train_test_split(df, test_size=0.3)


y_train, y_test = train.Survived, test.Survived
features = ["Pclass", "Sex", "Age", "SibSp", "Parch"]

X_train = train[features]
X_test = test[features]

RFC_model = RandomForestClassifier(n_estimators=100, max_depth=5)
RFC_model.fit(X_train, y_train)

# y_pred = RFC_model.predict(X_test)
# print(RFC_model.score(X_test, y_test))
# scores = cross_val_score(RFC_model, X_train, y_train, cv=10)
# print(scores.mean())

LR_model = LogisticRegression(random_state=42)
LR_model.fit(X_train, y_train)

SVC_model = SVC(kernel='linear', gamma=0.1, C=10)
SVC_model.fit(X_train, y_train)

while True:
        try:
            Pclass = int(input('Введіть клас: '))
            sex = input('Стать: ')
            age = int(input('Вік: '))
            SibSp = int(input('SibSp: '))
            Parch = int(input('Parch: '))
        except ValueError:
            print("Wrong data! Try again!")
            continue

        data = {'Pclass': Pclass, 'Sex': 1 if sex == 'male' else 0, 'Age': age, 'SibSp': SibSp, 'Parch': Parch, }
        input_data = pd.DataFrame(data, index=[0])

        print('RFC:')
        print('Survived' if RFC_model.predict(input_data)[0] == 1 else 'Dead')

        print('LR:')
        print('Survived' if LR_model.predict(input_data)[0] == 1 else 'Dead')

        print('SVC:')
        print('Survived' if SVC_model.predict(input_data)[0] == 1 else 'Dead')

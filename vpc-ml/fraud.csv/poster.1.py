import requests
import random
import json

params = {
  "Time": {
    "min": 0,
    "max": 172792,
    "mean": 94813.8595750807
  },
  "V1": {
    "min": -56.4075096313,
    "max": 2.4549299912,
    "mean": 0
  },
  "V2": {
    "min": -72.7157275629,
    "max": 22.0577289905,
    "mean": 5.6881744e-16
  },
  "V3": {
    "min": -48.3255893624,
    "max": 9.3825584328,
    "mean": -0
  },
  "V4": {
    "min": -5.6831711982,
    "max": 16.8753440336,
    "mean": 0
  },
  "V5": {
    "min": -113.7433067111,
    "max": 34.8016658767,
    "mean": -0
  },
  "V6": {
    "min": -26.1605059358,
    "max": 73.301625546,
    "mean": 0
  },
  "V7": {
    "min": -43.5572415712,
    "max": 120.5894939452,
    "mean": -0
  },
  "V8": {
    "min": -73.2167184553,
    "max": 20.0072083651,
    "mean": -1.927027709e-16
  },
  "V9": {
    "min": -13.4340663182,
    "max": 15.5949946071,
    "mean": -0
  },
  "V10": {
    "min": -24.5882624372,
    "max": 23.7451361207,
    "mean": 0
  },
  "V11": {
    "min": -4.7974734648,
    "max": 12.0189131816,
    "mean": 9.170318144e-16
  },
  "V12": {
    "min": -18.6837146333,
    "max": 7.8483920756,
    "mean": -0
  },
  "V13": {
    "min": -5.7918812063,
    "max": 7.1268829586,
    "mean": 0
  },
  "V14": {
    "min": -19.2143254903,
    "max": 10.5267660518,
    "mean": 0
  },
  "V15": {
    "min": -4.4989446768,
    "max": 8.8777415977,
    "mean": 0
  },
  "V16": {
    "min": -14.1298545175,
    "max": 17.3151115176,
    "mean": 0
  },
  "V17": {
    "min": -25.1627993693,
    "max": 9.2535262505,
    "mean": -7.528491456e-16
  },
  "V18": {
    "min": -9.498745921,
    "max": 5.0410691854,
    "mean": 4.328772269e-16
  },
  "V19": {
    "min": -7.2135274302,
    "max": 5.5919714273,
    "mean": 9.049732488e-16
  },
  "V20": {
    "min": -54.4977204946,
    "max": 39.4209042482,
    "mean": 5.085503397e-16
  },
  "V21": {
    "min": -34.8303821448,
    "max": 27.2028391573,
    "mean": 1.537293651e-16
  },
  "V22": {
    "min": -10.9331436977,
    "max": 10.5030900899,
    "mean": 7.95990853e-16
  },
  "V23": {
    "min": -44.8077352038,
    "max": 22.5284116898,
    "mean": 5.367589788e-16
  },
  "V24": {
    "min": -2.8366269187,
    "max": 4.5845491369,
    "mean": 0
  },
  "V25": {
    "min": -10.295397075,
    "max": 7.5195886787,
    "mean": 0
  },
  "V26": {
    "min": -2.6045505528,
    "max": 3.5173456116,
    "mean": 0
  },
  "V27": {
    "min": -22.5656793208,
    "max": 31.6121981061,
    "mean": -3.660160614e-16
  },
  "V28": {
    "min": -15.4300839055,
    "max": 33.8478078189,
    "mean": -1.206048853e-16
  },
  "Amount": {
    "min": 0,
    "max": 25691.16,
    "mean": 88.3496192509
  },
  "Class": {
    "min": 0,
    "max": 1,
    "mean": 0.0017274856
  }
}

for i in range(100):
  payload = {
    "features": [
      [
        0,
        random.uniform(params['V1']['min'],params['V1']['max']),
        random.uniform(params['V2']['min'],params['V2']['max']),
        random.uniform(params['V3']['min'],params['V3']['max']),
        random.uniform(params['V4']['min'],params['V4']['max']),
        random.uniform(params['V5']['min'],params['V5']['max']),
        random.uniform(params['V6']['min'],params['V6']['max']),
        random.uniform(params['V7']['min'],params['V7']['max']),
        random.uniform(params['V8']['min'],params['V8']['max']),
        random.uniform(params['V9']['min'],params['V9']['max']),
        random.uniform(params['V10']['min'],params['V10']['max']),
        random.uniform(params['V11']['min'],params['V11']['max']),
        random.uniform(params['V12']['min'],params['V12']['max']),
        random.uniform(params['V13']['min'],params['V13']['max']),
        random.uniform(params['V14']['min'],params['V14']['max']),
        random.uniform(params['V15']['min'],params['V15']['max']),
        random.uniform(params['V16']['min'],params['V16']['max']),
        random.uniform(params['V17']['min'],params['V17']['max']),
        random.uniform(params['V18']['min'],params['V18']['max']),
        random.uniform(params['V19']['min'],params['V19']['max']),
        random.uniform(params['V20']['min'],params['V20']['max']),
        random.uniform(params['V21']['min'],params['V21']['max']),
        random.uniform(params['V22']['min'],params['V22']['max']),
        random.uniform(params['V23']['min'],params['V23']['max']),
        random.uniform(params['V24']['min'],params['V24']['max']),
        random.uniform(params['V25']['min'],params['V25']['max']),
        random.uniform(params['V26']['min'],params['V26']['max']),
        random.uniform(params['V27']['min'],params['V27']['max']),
        random.uniform(params['V28']['min'],params['V28']['max']),
        25
      ]
    ]
  }

  #print payload
  r = requests.post("http://52.212.196.108:5000/predict", headers={"Content-Type": "application/json"}, json=payload)
  #print(r.text)

  data = json.loads(r.text)
  #print data['scores'][0]
  print "{0:.0f}%".format(data['scores'][0] * 100)
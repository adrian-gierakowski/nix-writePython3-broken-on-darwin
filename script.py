import yaml

y = yaml.load("""
  - test: success
""", Loader=yaml.FullLoader)
print(y[0]['test'])

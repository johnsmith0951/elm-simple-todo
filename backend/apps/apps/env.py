import pathlib

import environ

root = environ.Path(__file__) - 3  # リポジトリルートPATH
env = environ.Env()

if env("ENV_FILE", default=None):
    # ENV_FILE 環境変数で.envファイルを指定した場合
    env.read_env(env("ENV_FILE"))
elif pathlib.Path(root(".env")).is_file():
    # リポジトリrootに .env がある場合 （カレントではない）
    env.read_env(root(".env"))
else:
    pass  # use environment variables without .env file


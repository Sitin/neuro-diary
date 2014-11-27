Nuero Diary
============


Session
--------

To process data from session logs put logs to `input/session.json`. Then in console run

```bash
./process.py
```

You should get several `*.csv` files under `visualizer/data/` directory.

Then put your session audio to `visualizer/data/session.mp3`.

Open processing and load file `visualizer/visualizer.pde`.

Press run and have fun.


Tests
------

```bash
./runtests.py
```
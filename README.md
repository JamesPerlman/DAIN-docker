# DAIN-docker
Dockerfile for https://github.com/baowenbo/dain

# Run container
`docker pull jperldev/dain`

`docker run --gpus all -it jperldev/dain`

# Run DAIN inside container

`WORKDIR` is `/usr/local/dain` and conda env `pytorch1.0.0` should already be activated when you attach to a container.

Copy a video file (or a folder of video files) into the container, then run the following command (from `/usr/local/dain`):

```python dain_batch.py -i /path/to/input.mp4 -o /path/to/output/folder```

or

```python dain_batch.py -i /path/to/videos/folder -o /path/to/output/folder```

# dain_batch.py arguments

`-i, --in` - Input file or folder path

`-o, --out` - Output folder path

`--slow` - Slow motion multiplier. `--slow 8` means DAIN will create 7 interpolated output frames between each input frame pair, and the output fps will be 8x higher unless the `--fps` option is used. (default = 8)

`--loop` - Turn this on if you want the video to be able to loop seamlessly. (set to 1 or 0. default = 0)

`--fps` - Use this if you want to reinterpret the output footage at a specific framerate.  If your input video is 1 second in duration and has a framerate of 30fps and you use `--slow 8` then the output video will also have a duration of 1 second, but with a framerate of 240fps.  If you also specify `--fps 30` then your output video will be 8 seconds long with a framerate of 30fps. (default = 0)

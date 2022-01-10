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
`--slow` - Slow motion multiplier. `--slow 8` means output video should be 8x slower than input, i.e. create 7 interpolated output frames between each input frame pair. (default = 8)
`--loop` - Turn this on if you want the video to be able to loop seamlessly. (set to 1 or 0. default = 0)
`--fps` - Use this if you want to reinterpret the output footage at a specific framerate.  By default, the output framerate will be the input framerate multiplied by the slow motion multiplier, aka the output's duration will be identical to the input's duration. (default = 0)

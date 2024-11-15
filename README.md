# Run tests in prebuilt container: #

Clone this reposority with submodules:

`git clone --recurse-submodules git@github.com:rkarhila-amd/mila_rocm_docker.git`

A branch of milabench called pytorch2.5 is included as a submodule, and you'll need to make
sure that milabench code really is at that branch. (I think I messed up royally setting it up.)
Because this is still in development, this directory will be mounted inside the running container.

Then put your huggingface token in the marked place in the run script `scripts/run_in_rocm_container.sh`

Check the mounts in the `milabench_container_wrapper.sh` and edit to your liking -- Otherwise the script will 
mount `./results` directory into the container. The virtual envs stay in the container, but data and model cache 
as well as results will be written to the mounted directory on the host.

Then run your tests with wrapper script. For example, to run llama:

` ./milabench_container_wrapper.sh --select llama`




# Build the container: #

Clone the repo with submodules:

`git clone --recurse-submodules git@github.com:rkarhila-amd/mila_rocm_docker.git`

If your milabench submodule is not in `pytorch2.5` branch, do `git submodule update --remote` or some other
operation to put it in the correct branch.

To build:

` docker/build_and_push_mi250mi300_torch251_image.bash`

Patch it with the latest test code:

`docker build -f docker/Dockerfile-rocm-mi250mi300_torch251_patch -t mila-rocm-docker:torch2.5.1-mi250mi300-2024-11-09_patched .`

This will take some time.

While waiting for it to finish, put your huggingface token in the marked place 
in the run script `scripts/run_in_rocm_container.sh`.

Change the wrapper script ` ./milabench_container_wrapper.sh` to use your brand new image. 
 and then run your tests with wrapper script. For example, to run llama:

` ./milabench_container_wrapper.sh --select llama`


But don't run just yet. Check the mounts in the wrapper, they tell you where 
your results will be written. 

# Status on 2024 Nov 15th #

Runs now the "llm-*" tests om MI300:

```
bench                    | fail |   n | ngpu |       perf |   sem% |   std% | peak_memory |      score | weight
llama                    |    2 |  10 |    1 |     595.02 |   5.0% |  90.1% |       28777 |    3602.48 |   1.00
llm-full-mp-gpus         |    6 |   7 |    8 |     389.01 |   2.5% |  13.4% |       36512 |      55.57 |   1.00
llm-full-mp-nodes        |    2 |   2 |    0 |        nan |   nan% |   nan% |         nan |        nan |   1.00
llm-lora-ddp-gpus        |    4 |   5 |    8 |   29023.93 |   0.8% |   4.4% |       88865 |    5804.79 |   1.00
llm-lora-ddp-nodes       |    2 |   2 |    0 |        nan |   nan% |   nan% |         nan |        nan |   1.00
llm-lora-mp-gpus         |    4 |   5 |    8 |    3437.24 |   2.3% |  12.3% |       59343 |     687.45 |   1.00
llm-lora-single          |   11 |  19 |    1 |    5625.20 |   1.0% |  15.6% |       72048 |   19425.03 |   1.00
```

Lots of other tests broken. Probably a problem with container rather than code updates. Will be investigated next.


# Status on 2024 Nov 14th #

Some packages have been updated from original dependencies:

```
pytorch-triton-rocm     3.0.0          => 3.1.0
sympy                   1.13.3         => 1.13.1
torch                   2.4.1+rocm6.1  => 2.5.1+rocm6.1
torchao                 0.3.1          => 0.6.1
torchtune               0.2.1          => e1caa9f82fea24d728f9b244a9dd1957f5ed7465 
                                          (github commit from Nov 10th 2024)
torchvision             0.19.1+rocm6.1 => 0.19.1+rocm6.1
```

This forced a rewrite of the llm test recipes.

Tested on 8xMI250. Some tasks fail because they depend on cuda components now available for rocm, 
others fail because they run out of memory on the GPU.

```
=================
Benchmark results
=================
System
------
cpu:      AMD EPYC 7713 64-Core Processor
n_cpu:    128
product:  AMD INSTINCT MI250 (MCM) OAM AC MBA
n_gpu:    8
memory:   65520

Breakdown
---------
bench                    | fail |   n | ngpu |       perf |   sem% |   std% | peak_memory |      score | weight
brax                     |    0 |   1 |    8 |   99552.42 |   1.8% |  13.6% |        1442 |   99552.42 |   1.00
diffusion-gpus           |    0 |   1 |    8 |      99.35 |   0.0% |   0.3% |       59368 |      99.35 |   1.00
diffusion-single         |    0 |   8 |    1 |      12.69 |   0.5% |  11.9% |       55583 |     102.99 |   1.00
dimenet                  |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
dinov2-giant-gpus        |    1 |   1 |    8 |        nan |   nan% |   nan% |         nan |        nan |   1.00
dinov2-giant-single      |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
dqn                      |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
bf16                     |    0 |   8 |    1 |     147.62 |   0.4% |   9.9% |        1172 |    1192.48 |   0.00
fp16                     |    0 |   8 |    1 |     149.77 |   0.4% |   9.7% |        1172 |    1209.76 |   0.00
fp32                     |    0 |   8 |    1 |      38.73 |   0.4% |   9.7% |        4916 |     312.85 |   0.00
tf32                     |    0 |   8 |    1 |      38.74 |   0.4% |   9.7% |        1556 |     312.92 |   0.00
bert-fp16                |    0 |   8 |    1 |      48.56 |   2.6% |  40.6% |       52254 |     390.44 |   0.00
bert-fp32                |    0 |   8 |    1 |      28.96 |   2.2% |  33.9% |       57366 |     234.77 |   0.00
bert-tf32                |    0 |   8 |    1 |      29.49 |   2.3% |  36.0% |       57367 |     237.96 |   0.00
bert-tf32-fp16           |    0 |   8 |    1 |      57.64 |   3.2% |  50.5% |       52252 |     465.45 |   3.00
reformer                 |    0 |   8 |    1 |      27.81 |   0.5% |  10.9% |       24937 |     225.42 |   1.00
t5                       |    1 |   8 |    1 |      29.46 |   0.6% |  12.0% |       65487 |     182.92 |   2.00
whisper                  |    0 |   8 |    1 |     245.72 |   0.5% |  12.0% |        9979 |    1993.69 |   1.00
lightning                |    0 |   8 |    1 |     520.91 |   0.3% |   9.8% |       27272 |    4202.85 |   1.00
lightning-gpus           |    0 |   1 |    8 |    4061.71 |   0.3% |   3.2% |       27698 |    4061.71 |   1.00
llava-single             |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
llama                    |    0 |   8 |    1 |     249.82 |   5.0% |  90.0% |       33956 |    1882.89 |   1.00
llm-full-mp-gpus         |    1 |   1 |    8 |        nan |   nan% |   nan% |         nan |        nan |   1.00
llm-lora-ddp-gpus        |    0 |   1 |    8 |   10680.84 |   0.7% |   3.8% |       63926 |   10680.84 |   1.00
llm-lora-mp-gpus         |    1 |   1 |    8 |        nan |   nan% |   nan% |         nan |        nan |   1.00
llm-lora-single          |    0 |   8 |    1 |    1975.04 |   0.7% |  11.1% |       62298 |   16097.93 |   1.00
pna                      |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
ppo                      |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
recursiongfn             |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
rlhf-gpus                |    0 |   1 |    8 |   14157.26 |   0.3% |   1.8% |       25877 |   14157.26 |   1.00
rlhf-single              |    0 |   8 |    1 |    1886.36 |   0.5% |  10.7% |       29055 |   15255.09 |   1.00
torchatari               |    0 |   8 |    1 |    2180.08 |   0.4% |   9.6% |        3162 |   17616.78 |   1.00
convnext_large-fp16      |    0 |   8 |    1 |      85.51 |   1.0% |  16.1% |       27648 |     702.94 |   0.00
convnext_large-fp32      |    8 |   8 |    1 |        nan |   nan% |   nan% |       53705 |        nan |   0.00
convnext_large-tf32      |    8 |   8 |    1 |        nan |   nan% |   nan% |       43726 |        nan |   0.00
convnext_large-tf32-fp16 |    0 |   8 |    1 |      85.48 |   1.0% |  16.1% |       39027 |     702.69 |   3.00
regnet_y_128gf           |    0 |   8 |    1 |      23.67 |   2.2% |  48.3% |       65404 |     190.05 |   2.00
resnet152-ddp-gpus       |    0 |   1 |    8 |    3343.14 |   0.0% |   0.2% |       36638 |    3343.14 |   0.00
resnet50                 |    0 |   8 |    1 |     938.07 |   2.0% |  43.8% |       14612 |    7585.17 |   1.00
resnet50-noio            |    7 |   8 |    1 |     808.70 |   0.6% |  18.6% |       65509 |     101.09 |   0.00
vjepa-gpus               |    1 |   1 |    8 |        nan |   nan% |   nan% |         nan |        nan |   1.00
vjepa-single             |    8 |   8 |    1 |        nan |   nan% |   nan% |         nan |        nan |   1.00
```




Questions? Reach out to reima.karhila@amd.com.

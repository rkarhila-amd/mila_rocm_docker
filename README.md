
Build the container:

 docker/build_and_push_mi250mi300_torch251_image.bash


This will take some time.

While waiting for it to finish, put your huggingface token in the marked place 
in the run script scripts/run_in_rocm_container.sh

and then run your tests with wrapper script. For example, to run llama:

 ./milabench_container_wrapper.sh --select llama


But don't run just yet. Check the mounts in the wrapper, they tell you where 
your results will be written. Thw virtual envs stay in the container, but 
this script will have data and model cache as well as results on the host.


Status on November 7th 2024:

All multiprocessing benchmarks fail.
Some packages have been updated from original dependencies:

 - pytorch
 - triton
 - sympy
 - torchvision

I was experimenting updating also torchao and torchtune packages, but so 
far no luck in getting the mp tasks running. Might require more package 
updates or changing the launch parameters of the tasks.



Questions? Reach out to reima.karhila@amd.com.

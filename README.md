### Bayesian Semantic Segmentation

#### Note:

These models will only work on GPU based hardware due to the following reasons

- The CPU computations are painfully slow
- The models use the function `tf.nn.max_pool_with_argmax` for the unpooling operation which is built only for GPU (See Issue: [https://github.com/tensorflow/tensorflow/issues/6035]()). This has not been resolved for CPU

#### How to run on laptop without GPU
1. Amazon P2 instance
2. Google cloud GPU instance
3. Floydhub
4. Neptune

After creating a cloud instance with GPU, you can run
the script `cloud_deploy.sh` script in the repo to automatically install relevant packages for running models



#### Clone the repo

`$ git clone https://github.com/Arvinds-ds/segnet.git`

`$ cd segnet`

Follow the instructions for one of two scenarios :-

- Local GPU machines

- Cloud based GPU machines (simplifies a few steps)



#### A. Setup Environment (Non-cloud GPU machines)

`$ python3 -m venv ~/bayes-seg`

`$ source ~/bayes-seg/bin/activate bayes-seg`

`$ pip install -r requirements.txt`

#### B. Setup Environment (Cloud-Based GPU machines)
Post setting up a GPU instance with CUDA drivers properly installed

`$ ./cloud_deploy.sh bayes-seg`

Select Y to configure jupyter-notebook without password

`$ source ~/miniconda/envs/bayes-seg/bin/activate bayes-seg`

`$ jupyter-notebook --ip=0.0.0.0 --port=8888 --no-browser &`

Run the notebook from cloud using URL http://<instance_external_ip>:8888

##### Already Hosted Solution on GCP for running

Put URL when instance is up..



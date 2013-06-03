A comparison of Multi-class SVM strategies
==========================================

This work aims to compare different Multi-class strategies for Support 
Vector Machines (SVMs). Four different strategies have been explored:

* Multi-class formulation of SVMs
* Binary reduction of the multi-class problem:
    - One-vs-all
    - One-vs-one voting
    - One-vs-one DAG

The four strategies are empirically compared using the Landsat dataset and
the SVMlight software. Both are publicly available for research purposes.

The results compiled in the report can be independently checked using the
tools available in this repository. There is a brief guide bellow that
explains how to reproduce these results.

1. Read the `README.md` files in the svm_light and svm_multiclass directories
to obtain the required software.

2. Read the `README.md` file in the Data directory to obtain the data used to
perform the experiments.

3. Convert the training and test data to SVMlight format using the
`Prepare-SVMlight-Format.sh` script.

4. Normalize first the training data using the `Normalize-Data.py` 
script. Then, use the same script but now using the -s option and the 
generated `Data/sat6.tra.svmlight.norm.stats` file to normalize the
test data using the mean and standard deviation in the training data.
You can also try to scale the features instead of normalizing them by
using the script `Scale-Data.py`.

5. Create the 5-fold cross-validation partitions from the original training 
data using the `Prepare-KFold.py` script. Use the default random seed (0) to
generate the 5-fold CV files.

6. Run the different experiments using the linear kernel and the RBF kernel
using the `Run-Experiments.sh` script:

```bash
./Run-Experiments.sh -m MULTI ONE-VS-REST ONE-VS-ONE-VOTE ONE-VS-ONE-DAG \
-o Exper -tr Data/sat6c.tra.svmlight.norm.train+([0-9]) \
-va Data/sat6c.tra.svmlight.norm.valid+([0-9]) -t 0 -c 0.0009765625 \
0.001953125 0.00390625 0.0078125 0.015625 0.03125 0.0625 0.125 0.25 0.5 1 2 \
4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 \
524288 1048576 > Results-Linear.txt

./Run-Experiments.sh -m MULTI ONE-VS-REST ONE-VS-ONE-VOTE ONE-VS-ONE-DAG \
-o Exper -tr Data/sat6c.tra.svmlight.norm.train+([0-9]) \
-va Data/sat6c.tra.svmlight.norm.valid+([0-9]) -t 2 -c 0.0009765625 \
0.001953125 0.00390625 0.0078125 0.015625 0.03125 0.0625 0.125 0.25 0.5 1 2 \
4 8 16 32 64 128 256 512 1024 2048 4096 8192 -g 0.000030517578125 \
0.00006103515625 0.0001220703125 0.000244140625 0.00048828125 0.0009765625 \
0.001953125 0.00390625 0.0078125 0.015625 0.03125 0.0625 0.125 0.5 \
1 2 4 8 > Results-RBF.txt
```
This can take a long time to complete, especially due to the use of 
the multiclass version of SVMlight which is not optimized for kernels. 
These experiments will also create a bunch of files in the `Exper` directory 
which can also need several GB of disk. The results will be written to the 
`Results-Linear.txt` and `Results-RBF.txt` files.


If you need any help, contact the author.

Joan Puigcerver i Pérez 
joapuipe@upv.es

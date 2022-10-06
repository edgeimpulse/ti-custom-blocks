#!/usr/bin/env python3
# -*- coding:utf-8 -*-
import os

from yolox.exp import Exp as MyExp


class Exp(MyExp):
    def __init__(self):
        super(Exp, self).__init__()
        self.depth = 0.33
        self.width = 0.50
        self.exp_name = os.path.split(os.path.realpath(__file__))[1].split(".")[0]

        # Define yourself dataset path
        self.data_dir = "../home"
        self.train_ann = "images"
        self.val_ann = "labels"

        self.num_classes = 1

        self.max_epoch = 50
        self.data_num_workers = 4
        self.eval_interval = 1

#!/bin/bash
set -e

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

cd $SCRIPTPATH

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --epochs) # e.g. 50
      EPOCHS="$2"
      shift # past argument
      shift # past value
      ;;
    --learning-rate) # e.g. 0.01
      LEARNING_RATE="$2"
      shift # past argument
      shift # past value
      ;;
    --data-directory) # e.g. 0.2
      DATA_DIRECTORY="$2"
      shift # past argument
      shift # past value
      ;;
    --out-directory) # e.g. (96,96,3)
      OUT_DIRECTORY="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

if [ -z "$EPOCHS" ]; then
    echo "Missing --epochs"
    exit 1
fi
if [ -z "$LEARNING_RATE" ]; then
    echo "Missing --learning-rate"
    exit 1
fi
if [ -z "$DATA_DIRECTORY" ]; then
    echo "Missing --data-directory"
    exit 1
fi
if [ -z "$OUT_DIRECTORY" ]; then
    echo "Missing --out-directory"
    exit 1
fi

OUT_DIRECTORY=$(realpath $OUT_DIRECTORY)
DATA_DIRECTORY=$(realpath $DATA_DIRECTORY)

IMAGE_SIZE=$(python3 get_image_size.py --data-directory "$DATA_DIRECTORY")

# convert Edge Impulse dataset (in Numpy format, with JSON for labels into something YOLOv5 understands)
python3 -u extract_dataset.py --data-directory $DATA_DIRECTORY --out-directory /tmp/data

cd /app/edgeai-yolox
# train
echo "...training..."
python3 -m yolox.tools.train -f exps/default/yolox_s_ti_lite.py -d 0 -b 64 --fp16 -o 
echo "Training complete"
echo ""

# export as f32
# echo "Converting to TensorFlow Lite model (fp16)..."
# python3 -u export.py --weights ./runs/train/yolov5s_results/weights/last.pt --img $IMAGE_SIZE --include tflite
# cp runs/train/yolov5s_results/weights/last-fp16.tflite /home/model.tflite
# echo "Converting to TensorFlow Lite model (fp16) OK"
# echo ""

# export as i8 (skipping for now for speed)
# echo "Converting to TensorFlow Lite model (int8)..."
# chronic python3 -u export.py --weights ./runs/train/yolov5s_results/weights/last.pt --img $IMAGE_SIZE --include tflite --int8
# cp runs/train/yolov5s_results/weights/last-int8.tflite /home/model_quantized_int8_io.tflite
# echo "Converting to TensorFlow Lite model (int8) OK"
# echo ""

import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, Dropout, GlobalAveragePooling2D
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from sklearn.preprocessing import LabelEncoder
import joblib

# ---------------- Paths ----------------
DATASET_DIR = "dataset_images"
MODEL_PATH = os.path.join("dataset", "sign_language_mobilenet.h5")
ENCODER_PATH = os.path.join("dataset", "label_encoder_mobilenet.pkl")
os.makedirs("dataset", exist_ok=True)

# ---------------- Parameters ----------------
IMG_SIZE = 128
BATCH_SIZE = 32
EPOCHS = 20
LR = 1e-4

# ---------------- Load Dataset ----------------
datagen = ImageDataGenerator(
    rescale=1.0/255.0,
    validation_split=0.2,
    rotation_range=15,
    zoom_range=0.2,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    horizontal_flip=True
)

train_gen = datagen.flow_from_directory(
    DATASET_DIR,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="sparse",
    subset="training"
)

val_gen = datagen.flow_from_directory(
    DATASET_DIR,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="sparse",
    subset="validation"
)

# ---------------- Label Encoder ----------------
label_encoder = LabelEncoder()
label_encoder.fit(list(train_gen.class_indices.keys()))
joblib.dump(label_encoder, ENCODER_PATH)
print(f"✅ Saved label encoder to {ENCODER_PATH}")

# ---------------- Model ----------------
base_model = MobileNetV2(weights="imagenet", include_top=False, input_shape=(IMG_SIZE, IMG_SIZE, 3))
base_model.trainable = False  # freeze for transfer learning

x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(256, activation="relu")(x)
x = Dropout(0.4)(x)
preds = Dense(train_gen.num_classes, activation="softmax")(x)

model = Model(inputs=base_model.input, outputs=preds)
model.compile(optimizer=Adam(learning_rate=LR), loss="sparse_categorical_crossentropy", metrics=["accuracy"])

model.summary()

# ---------------- Train ----------------
history = model.fit(
    train_gen,
    validation_data=val_gen,
    epochs=EPOCHS
)

# ---------------- Fine-Tuning ----------------
print("\n🔧 Fine-tuning the top layers...")
base_model.trainable = True
for layer in base_model.layers[:-40]:
    layer.trainable = False

model.compile(optimizer=Adam(learning_rate=1e-5), loss="sparse_categorical_crossentropy", metrics=["accuracy"])
history_fine = model.fit(train_gen, validation_data=val_gen, epochs=5)

# ---------------- Save ----------------
model.save(MODEL_PATH)
print(f"✅ Model saved to {MODEL_PATH}")

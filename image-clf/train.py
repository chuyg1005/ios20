import torch
import time
from torch import nn
from torchvision import datasets, transforms
from torch.utils.data.dataloader import DataLoader
from torch import optim
from lenet import LeNet
from resnet import ResNet
import os
from matplotlib import pyplot as plt
import numpy as np
# from onnx_coreml import convert
from coremltools.converters.onnx import convert


def load_data(batch_size):
    # print('start downloading dataset')
    transformer = transforms.Compose([
        transforms.ToTensor(),  # 从image转换为tensor
        transforms.Normalize(mean=[0.493, 0.480, 0.443], std=[0.243, 0.239, 0.259])
    ])
    # batch_size = 100
    # 一次会同时下载训练集和测试集
    train = DataLoader(
        datasets.CIFAR10(root='./cifar10', train=True, transform=transformer, download=True),
        batch_size=batch_size,
        shuffle=True
    )
    test = DataLoader(
        datasets.CIFAR10(root='./cifar10', train=False, transform=transformer, download=True),
        batch_size=batch_size,
        shuffle=True
    )
    return train, test


def train_model(train, test):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    # model: nn.Module = LeNet()
    model: nn.Module = ResNet()
    model = model.to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters())
    start = time.time()

    for epoch in range(10):
        total_train = 0.0
        correct_train = 0.0

        model.train()
        for i, (X, y) in enumerate(train):
            X, y = X.to(device), y.to(device)
            logits = model(X)

            labels = logits.argmax(dim=1)
            correct_train += (labels == y).sum().item()
            total_train += y.numel()

            loss = criterion(logits, y)

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

        # test
        model.eval()
        with torch.no_grad():
            total_test = 0.0
            correct_test = 0.0
            for X, y in test:
                X, y = X.to(device), y.to(device)
                logits: torch.Tensor = model(X)
                labels = logits.argmax(dim=1)
                correct_test += (labels == y).sum().item()
                total_test += y.numel()
            print(f'epoch = {epoch}, train acc = {correct_train / total_train}, test acc = {correct_test / total_test}')

    end = time.time()
    print('training model finished, cost = ', end - start)
    return model


def load_model(path):
    model: nn.Module = ResNet()
    model.load_state_dict(torch.load(path))
    return model


def save_as_onnx(model, onnx_path):
    dummy_input = torch.rand(1, 3, 32, 32)
    input_names = ['image']
    output_names = ['classLabelProbs']
    torch.onnx.export(model, dummy_input, onnx_path, verbose=True,
                      input_names=input_names, output_names=output_names)


if __name__ == '__main__':
    PATH = './cifar_net'
    if os.path.exists(PATH):
        model = load_model(PATH)
    else:
        batch_size = 100
        train, test = load_data(batch_size)
        model = train_model(train, test)
        torch.save(model.state_dict(), PATH)

    onnx_path = 'cifar_net.onnx'
    save_as_onnx(model, onnx_path)
    classes = ['plane', 'car', 'bird', 'cat', 'deer',
               'dog', 'frog', 'horse', 'ship', 'truck']
    model = convert(model=onnx_path,
                    minimum_ios_deployment_target='13',
                    image_input_names=['image'],
                    mode='classifier',
                    predicted_feature_name='classLabel',
                    class_labels=classes)
    model.save('cifar_net.mlmodel')

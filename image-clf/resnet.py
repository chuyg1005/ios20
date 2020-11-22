import torch
from torch import nn
from torch.nn import functional as F


class ResBlk(nn.Module):
    def __init__(self, in_channel, out_channel, stride=1):
        super().__init__()
        self.blk = nn.Sequential(
            nn.Conv2d(in_channel, out_channel, kernel_size=3, stride=stride, padding=1),
            nn.BatchNorm2d(out_channel),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_channel, out_channel, kernel_size=3, stride=1, padding=1),
            nn.BatchNorm2d(out_channel)
        )
        self.shortcut = nn.Sequential()
        if stride != 1 or in_channel != out_channel:
            self.shortcut = nn.Sequential(
                nn.Conv2d(in_channel, out_channel, kernel_size=1, stride=stride, padding=0),
                nn.BatchNorm2d(out_channel)
            )

    def forward(self, x):
        out = self.blk(x) + self.shortcut(x)
        return F.relu(out)


class ResNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(3, 64, kernel_size=3, stride=1, padding=0),
            nn.BatchNorm2d(64),
            nn.ReLU()
        )
        self.layers = nn.Sequential(
            ResBlk(in_channel=64, out_channel=64, stride=1),
            ResBlk(in_channel=64, out_channel=64, stride=1),
            ResBlk(in_channel=64, out_channel=128, stride=2),
            ResBlk(in_channel=128, out_channel=128, stride=1),
            ResBlk(in_channel=128, out_channel=256, stride=2),
            ResBlk(in_channel=256, out_channel=256, stride=1),
            ResBlk(in_channel=256, out_channel=512, stride=2),
            ResBlk(in_channel=512, out_channel=512, stride=1)
        )
        self.fc = nn.Linear(512, 10)

    def forward(self, x):
        out = self.conv(x)
        out = self.layers(out)
        out = F.avg_pool2d(out, 4)
        return self.fc(out.view(-1, 512))


if __name__ == '__main__':
    x = torch.randn(1, 3, 32, 32)
    model = ResNet()
    y = model(x)
    # print(x, model(x))

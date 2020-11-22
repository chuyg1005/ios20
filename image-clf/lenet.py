from torch import nn


class LeNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv_unit = nn.Sequential(
            nn.Conv2d(3, 6, kernel_size=5, stride=1, padding=0),
            nn.MaxPool2d(kernel_size=2, stride=2),
            nn.Conv2d(6, 16, kernel_size=5, stride=1, padding=0),
            nn.MaxPool2d(kernel_size=2, stride=2)
        )
        self.fc_unit = nn.Sequential(
            nn.Linear(16 * 5 * 5, 120),
            nn.ReLU(),
            nn.Linear(120, 84),
            nn.ReLU(),
            nn.Linear(84, 10)
        )

    def forward(self, x):
        x = self.conv_unit(x)
        x = x.view(x.size(0), -1)
        x = self.fc_unit(x)
        return x

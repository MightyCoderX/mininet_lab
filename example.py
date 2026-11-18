from mininet.cli import CLI
from mininet.log import setLogLevel
from mininet.net import Mininet
from mininet.node import Node, OVSBridge


class LinuxRouter(Node):
    def config(self, ip=None, **args):
        self.cmd("sysctl -w net.ipv4.ip_forward=1")
        return super().config(ip=None, **args)

    def terminate(self):
        self.cmd("sysctl -w net.ipv4.ip_forward=0")
        super().terminate()


def main():
    net = Mininet(switch=OVSBridge, controller=None)

    r1 = net.addHost("r1", cls=LinuxRouter)
    r2 = net.addHost("r2", cls=LinuxRouter)

    net.addLink(
        r1,
        r2,
        intfName1="r1-eth0",
        params1={"ip": "172.16.0.0/31"},
        intfName2="r2-eth0",
        params2={"ip": "172.16.0.1/31"},
    )

    # router1 hosts, net: 192.168.0.0/24
    s1 = net.addSwitch("s1")
    net.addLink(r1, s1, intfName1="r1-eth1", params1={"ip": "192.168.0.254/24"})
    for i in range(1, 4):
        host = net.addHost(
            f"r1_h{i}", ip=f"192.168.0.{i}/24", defaultRoute="via 192.168.0.254"
        )
        net.addLink(host, s1)

    # router2 hosts, net: 192.168.1.0/24
    s2 = net.addSwitch("s2")
    net.addLink(r2, s2, intfName1="r2-eth1", params1={"ip": "192.168.1.254/24"})
    for i in range(1, 4):
        host = net.addHost(
            f"r2_h{i}", ip=f"192.168.1.{i}/24", defaultRoute="via 192.168.1.254"
        )
        net.addLink(host, s2)

    net.start()

    r1.cmd("ip route add 192.168.1.0/24 via 172.16.0.1")
    r2.cmd("ip route add 192.168.0.0/24 via 172.16.0.0")

    net.pingAll(timeout=".1s")

    CLI(net)
    net.stop()


if __name__ == "__main__":
    setLogLevel("info")
    main()

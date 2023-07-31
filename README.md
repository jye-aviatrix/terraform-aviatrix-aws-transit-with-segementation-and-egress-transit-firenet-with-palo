
## Architecture

![architecture](architecture.png)
- This repo deploys two Aviatrix Transits, one of them is dedicated egress transit FireNet with Palo.
- To save cost, HA gateways are not deployed
- Two spoke VPCs are in separate network domain, no connection policy configured.

## Palo Password
```
YW3usHoAhrFEw0WiwFfd
```

## Vendor integration

Go to Controller > Firewall Network > Vendor Integration > Select Firewall -> Edit

![Vendor integration](20230731170758.png)

Change Firewall Vendor Type -> Palo Alto Network VM-Series
Firewall Login User Name -> Admin
Firewall Login Password -> ****

Click on Save

Aviatrix Controller will then be able to manage the route table in the firewall:
![example](20230731171156.png)

## Reference



[Aviatrix Transit FireNet - Configuring Palo Alto in AWS](https://docs.aviatrix.com/documentation/latest/firewall-and-security/firenet-paloalto-aws.html)
[Aviatrix - Bootstrap Configuration Example for VM-Series in AWS](https://docs.aviatrix.com/documentation/latest/firewall-and-security/paloalto-bootstrap-aws.html)
[Palo Alto - Bootstrap](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-aws)

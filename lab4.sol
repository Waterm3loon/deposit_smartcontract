// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1 <0.9.0;

contract bank{
    
    address public owner;

    enum Statuses{VIP,General}

    struct Customer{
        string name;
        uint customerBalance;
        Statuses status;
        uint registrationTime;
        uint lastDepositTime;
    }

    mapping(address=>Customer) public customers;

    constructor(){
        owner=msg.sender;
    }

    function registration(string memory _name) external{
        require(customers[msg.sender].registrationTime==0,"Already registrated!");
        customers[msg.sender]=Customer(_name,0,Statuses.General,block.timestamp,0);
    }

    function deposit() external payable {
        require(customers[msg.sender].registrationTime>0,"You are not registered");
        customers[msg.sender].customerBalance+=msg.value;
        customers[msg.sender].lastDepositTime = block.timestamp;
    }

    function customerBalance() external view returns(uint){
        return customers[msg.sender].customerBalance;
    }

    function balanceSC() external view returns(uint){
        return address(this).balance;
    }

    function withdrawal(uint _value, address _to) external {
        require(customers[msg.sender].registrationTime>0,"You are not registered!");
        require(customers[msg.sender].customerBalance>=_value,"Insufficient money!");
        require(_value>0,"Incorrect value!");
        customers[msg.sender].customerBalance-=_value;
        payable(_to).transfer(_value);
    }

    // 4. вывод для владельца контракта
    function ownerWithdrawal(uint _value, address _to) external {
        require(msg.sender == owner, "Only owner can call this function");
        require(address(this).balance >= _value, "Insufficient contract balance");
        payable(_to).transfer(_value);
    }

    // 5. выдача VIP статуса
    function grantVIP(address _customer) external {
        require(msg.sender == owner, "Only owner can call this function");
        require(customers[_customer].registrationTime > 0, "Customer not registered");
        require(customers[_customer].status == Statuses.General, "Already VIP");
        customers[_customer].status = Statuses.VIP;
    }

    // 6. начисление процентов (5% годовых для General, 10% для VIP; начисляется на основе времени с последнего депозита)
    function accrueInterest() external {
        require(customers[msg.sender].registrationTime > 0, "You are not registered");
        require(customers[msg.sender].lastDepositTime > 0, "No deposits made yet");
        uint timeElapsed = block.timestamp - customers[msg.sender].lastDepositTime;
        if (timeElapsed == 0) return;
        uint rate = (customers[msg.sender].status == Statuses.VIP) ? 10 : 5;
        uint yearInSeconds = 365 days;
        uint interest = (customers[msg.sender].customerBalance * rate * timeElapsed) / (100 * yearInSeconds);
        customers[msg.sender].customerBalance += interest;
        customers[msg.sender].lastDepositTime = block.timestamp;
    }

    // 7. оплата за услуги (владелец взимает плату с клиента, сумма остается в контракте как прибыль)
    function chargeServiceFee(address _customer, uint _amount) external {
        require(msg.sender == owner, "Only owner can call this function");
        require(customers[_customer].registrationTime > 0, "Customer not registered");
        require(customers[_customer].customerBalance >= _amount, "Insufficient customer balance");
        customers[_customer].customerBalance -= _amount;
    }
}
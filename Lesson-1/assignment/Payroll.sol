pragma solidity ^0.4.14;
contract Payroll {

    address employee;
    uint salary;
    uint constant payDuration = 1 seconds;
    uint lastPayDay;
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunOut() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunOut() > 0;
    }

    function getPaid() payable returns (uint){
        if (msg.sender != employee) {
            revert();
        }
        uint nextPayDay = lastPayDay + payDuration;
        if (nextPayDay > now) {
            revert();
        }
        lastPayDay = nextPayDay;
        employee.transfer(salary);
        return this.balance;
    }
    
    function udpateEmployee(address e, uint s) { /**here address parameter need to add double quote on remix **/
       
        employee = e;
        salary = s * 1 ether;
        lastPayDay = now;
    } 
}
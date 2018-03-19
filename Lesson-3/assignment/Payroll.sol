pragma solidity ^0.4.18;

/* add quotes to the address when debug in remix */
import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable{
    using SafeMath for uint;
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    uint constant payDuration = 10 seconds;
    uint private totalSalary = 0;
    address owner;
    mapping(address => Employee) public employees;
    
    modifier employeeExists(address employeeId){
        var employee = employees[employeeId];
        require(employee.id != 0x0);
        _;
    }
    
    modifier deleteEmployee(address employeeId){
        _;
        delete employees[employeeId];
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        _payEmployee(employee, payment, now);
    }
    
    // pay employee
    function _payEmployee(Employee employee, uint payment, uint time) private{
        employee.lastPayday = time;
        employee.id.transfer(payment);
    }
    
    function addEmployee(address employeeId, uint salary) public onlyOwner{
        var employee = employees[employeeId];
        if (employee.id == 0x0) {
            employees[employeeId] = Employee(employeeId, salary.mul(1 ether), now);
            totalSalary = totalSalary.add(employees[employeeId].salary);
        }
    }
    
    function removeEmployee(address employeeId) public onlyOwner employeeExists(employeeId) deleteEmployee(employeeId){
            var employee = employees[employeeId];
            _partialPaid(employee);
            totalSalary = totalSalary.sub(employee.salary);
    }
    
    function updateEmployee(address employeeId, uint salary) public onlyOwner employeeExists(employeeId) {
        var employee = employees[employeeId];
        _partialPaid(employee);
        uint newSalary = salary.mul(1 ether);
        totalSalary = totalSalary.sub(employee.salary).add(newSalary);
        employee.salary = newSalary;
    }
    
    function changePaymentAddress(address newAddress) public employeeExists(msg.sender) deleteEmployee(msg.sender){
        var employee = employees[msg.sender];
        employee.id = newAddress;
        employees[newAddress] = employee;
    }
    
    function addFund() payable public returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() public view returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public employeeExists(msg.sender){
        var employee = employees[msg.sender];
        uint nextPayday = employee.lastPayday.add(payDuration);
        if(nextPayday > now){
            revert();
        }
        _payEmployee(employee, employee.salary, nextPayday);
    }
}
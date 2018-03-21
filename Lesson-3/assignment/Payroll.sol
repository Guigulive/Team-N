pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

 contract Payroll is Ownable{
     using SafeMath for uint;
     struct Employee{
         address id;
         uint salary;
         uint lastPayday;
     }

     uint constant payDuration = 10 seconds;
     uint totalSalary;
     address owner;
     mapping(address => Employee) public employees;

     modifier employeeExist(address employeeId) {
       var employee = employees[employeeId];
       assert(employee.id != 0x0);
       _;
     }
     
     modifier deleteEmployee(address employeeId) {
         _;
         delete employees[employeeId];
     }

     function _partialPaid  (Employee employee)  private {
          uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
          employee.id.transfer(payment);

     }

     function addEmployee(address employeeId, uint salary) onlyOwner {
         var employee = employees[employeeId];
         assert(employee.id == 0x0);
         employees[employeeId] = Employee(employeeId,salary.mul(1 ether),now);
         totalSalary = totalSalary.add(employees[employeeId].salary);
     }

     function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) deleteEmployee(employeeId) {
         var employee = employees[employeeId];
         _partialPaid(employee);
         totalSalary = totalSalary.sub(employee.salary);
         //delete employees[employeeId];
     }

     function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
         var employee = employees[employeeId];
         _partialPaid(employee);
         totalSalary = totalSalary.sub(employees[employeeId].salary); 
         employees[employeeId].salary = salary.mul(1 ether);
         totalSalary = totalSalary.add(employees[employeeId].salary);
         employees[employeeId].lastPayday = now;
     }
     
     function changePaymentAddress(address newEmployeeId) employeeExist(msg.sender) deleteEmployee(msg.sender) {
         var employee = employees[msg.sender];
         employee.id = newEmployeeId;
         employees[newEmployeeId] = employee;
         // delete employees[msg.sender];
     }

     function addFund() payable returns (uint) {
         return this.balance;
     }

     function calculateRunway() returns (uint) {
         return this.balance / totalSalary;
     }

     function hasEnoughFund() returns (bool) {
         return calculateRunway() > 0;
     }

     //得到某个员工相关信息
     function checkEmployee(address employeeId) returns (uint salary, uint lastPayday) {
         var employee = employees[employeeId];
         /* return (employee.salary, employee.lastPayday); */
         salary = employee.salary;
         lastPayday = employee.lastPayday;
     }

     function getPaid() employeeExist(msg.sender) {
         var employee = employees[msg.sender];

         uint nextPayday = employee.lastPayday + payDuration;
         assert(nextPayday < now);

         employees[msg.sender].lastPayday = nextPayday;
         employee.id.transfer(employee.salary);
     }

 }

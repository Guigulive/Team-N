pragma solidity ^0.4.14;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }
        
    uint constant payDuration = 1 seconds;
    address employer = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    Employee[] employees;
    uint totalSalary = 0;
    
    function Payroll() {
        employer = msg.sender;
    }
    
    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == employer);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x00);
        totalSalary += salary;
        employees.push(Employee(employee.id, salary, now));
    }
    
    
    function removeEmployee(address employeeId) {
       require(msg.sender == employer);
       var (employee, index) = _findEmployee(employeeId);
       assert(employeeId != 0x00);
        _partialPay(employee);
        totalSalary -= employees[index].salary;
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
        return;
    }
    
    function _partialPay(Employee e)  private {
        uint payment = e.salary * (now - e.lastPayDay / payDuration);
        e.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee,uint) {
        for(uint i = 0; i < employees.length; i++) { // check duplicate employee
            if (employees[i].id == employeeId) {
                return (employees[i],i);
            }
     }
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunOut() returns (uint) {
      /*  uint total = 0;
        for(uint i = 0; i < employees.length; i++) {
            total += employees[i].salary;
        }*/
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunOut() > 0;
    }

    function getPaid() payable returns (uint){
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x00);
        
        require(msg.sender == employee.id);
        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);
        
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
        return this.balance;
    }
    
    function udpateEmployee(address e, uint s) { /**here address parameter need to add double quote on remix **/
        require(msg.sender == employer);
        var (employee, index) = _findEmployee(e);
        assert(e != 0x00);
        _partialPay(employee);
        uint diff = s - employee.salary;
        employee.salary = s * 1 ether;
        totalSalary += diff;
        employee.lastPayDay = now;
    } 
}
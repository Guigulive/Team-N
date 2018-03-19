pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
  
    uint constant payDuration = 10 seconds;
    
    address owner;
    Employee[] employees;
    
    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
            return (employees[i], i);
            }
        }
    }
    
    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
    
        employees.push(Employee(employeeId, salary * 1 ether, now));
    }
    
    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0); 
        _partialPaid(employee);
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }
    
    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function caculateRunway() returns(uint) {
        uint totalSalary = 0;
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns(bool) {
        return caculateRunway() > 0;
    }
    
    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
    
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
    
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}

// gas 消耗
/*
calculateRunway	transaction cost (gas)	execution cost (gas)
1	22966	1694
2	23747	2475
3	24528	3256
4	25309	4037
5	26090	4818
6	26871	5599
7	27652	6380
8	28433	7161
9	29214	7942
10	29995	8723
每addEmployee一次，calculateRunway的gas增加781
*/

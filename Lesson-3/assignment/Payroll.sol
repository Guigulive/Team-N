pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

//员工薪酬智能合约系统
contract Payroll is Ownable {
    using SafeMath for uint;
    
	//员工对象，包含收款地址id , 薪酬salary , 上一次薪酬发放时间lastPayday 
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
	//薪酬发放周期
    uint constant payDuration = 10 seconds;

	//总薪酬
    uint totalSalary;
	
    //收款地址和员工对象Map
    mapping(address => Employee) public employees;

    modifier employeeExist(address employeeId){
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
	
    modifier deleteEmployee(address employeeId) {
     _;
     delete employees[employeeId];
    }
    
	//执行支付
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary
            .mul(now.sub(employee.lastPayday))
            .div(payDuration);
        employee.id.transfer(payment);
    }

	//添加员工
    function addEmployee(address employeeId, uint salary) onlyOwner{
        var employee = employees[employeeId];
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId,salary * 1 ether,now);
    }
    //添加员工
    function addEmployeeWithLastPayday(address employeeId, uint salary, uint lastPayday) onlyOwner{
        var employee = employees[employeeId];
        
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId,salary * 1 ether,lastPayday);
    }
    //移除员工
    function removeEmployee(address employeeId) onlyOwner deleteEmployee(employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
    }
    //更新员工收款地址和薪酬
    function updateEmployee(address employeeId, uint salary) onlyOwner{
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        employees[employeeId].salary = salary * 1 ether;
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId].lastPayday = now;
    }
    
	//更改员工收款地址
    function changePaymentAddress(address newEmployeeId) onlyOwner employeeExist(msg.sender) deleteEmployee(msg.sender){
	   var employee = employees[msg.sender];
       employee.id = newEmployeeId;
       employees[newEmployeeId] = employee;
    }
    
	//向总账户汇入资金
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
	//剩余资金还能支付的薪酬次数
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
	
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
	//员工调用此方法给自己发工资
    function getPaid() employeeExist(msg.sender){
        var employee = employees[msg.sender];

        uint nextPayday =  employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
import './Ownable.sol';
pragma solidity ^0.4.14;

contract Payroll is Ownable {

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }
        
    uint constant payDuration = 10 seconds;
    address employer = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    mapping(address => Employee) public employees;
    uint totalSalary = 0;
    
    function Payroll() {
        employer = msg.sender;
    }
    
    modifier checkEmployeeModifier(address employeeId) {
          assert(employeeId != 0x00);
          _;
    }
    
    function addEmployee(address employeeId, uint salary)  onlyOwner {
     //   require(msg.sender == employer);
        var employee = employees[employeeId];
        assert(employee.id == 0x00);
        totalSalary += salary;
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
    }
    
    
    function removeEmployee(address employeeId) onlyOwner checkEmployeeModifier(employeeId) {
   //    require(msg.sender == employer);
        var employee = employees[employeeId];
        _partialPay(employee);
        totalSalary -= employees[employeeId].salary;
        delete employees[employeeId];
/*        employees[employeeId] = employees[employees.length - 1];
        employees.length -= 1;*/
        return;
    }
    
    function _partialPay(Employee e)  private {
        uint payment = e.salary * (now - e.lastPayDay / payDuration);
        e.id.transfer(payment);
    }
    
/* this is for loop waste too much gas, we can use mapping instead   
function _findEmployee(address employeeId) private returns (Employee,uint) {
        for(uint i = 0; i < employees.length; i++) { // check duplicate employee
            if (employees[i].id == employeeId) {
                return (employees[i],i);
            }
     }
    }*/
    
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
    
    
    function checkEmployee(address employeeId) returns (uint salary, uint lastPayDay) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayDay = employee.lastPayDay;
    }

    function getPaid() public {
        var employee = employees[msg.sender];
     //   assert(employee.id != 0x00);
        
        require(msg.sender == employee.id);
        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);
        
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary * 1 ether);
    }
    
    function udpateEmployee(address e, uint s) onlyOwner checkEmployeeModifier(e) { /**here address parameter need to add double quote on remix **/
      //  require(msg.sender == employer);
        var employee = employees[e];
        /*assert(e != 0x00);*/
        _partialPay(employee);
        uint diff = s - employee.salary;
        employee.salary = s * 1 ether;
        totalSalary += diff;
        employee.lastPayDay = now;
    } 
}
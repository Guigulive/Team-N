pragma solidity ^0.4.14;

contract PayRoll {

  function PayRoll() {
        adminAddr = msg.sender;
    }

  struct Employee {
        address employeeAddress;
        uint salary;
        uint lastPayDay;
    }
    
    mapping(address => Employee) public employees;
    
    Employee public employee;
    uint totalSalary;
    uint constant payDuration = 10 seconds;
    address adminAddr;
    
    
    
    //给部分function加管理员权限 
    modifier onlyAdmin(){
        require(msg.sender == adminAddr);
        _;
    }
    
    //确定地址不存在 
    modifier employeeAddressEqNull(address addr){
         employee = employees[addr];
         assert(employee.employeeAddress == 0x0);
         _;
    }
    
    //确定地址存在 
    modifier employeeAddressNotNull(address addr){
         employee = employees[addr];
         assert(employee.employeeAddress != 0x0);
         _;
    }
    
    // 统一支付方法 
    function _partialPaid(Employee e) private returns (bool) {
        uint payment = e.salary * (now - e.lastPayDay) / payDuration;
        if(payment > 0){
            e.employeeAddress.transfer(payment);
            return true;
        }else{
            return false;
        }
    }
    
    
    //添加人员
    function addEmployee(address employeeAddr,uint salary) onlyAdmin employeeAddressEqNull(employeeAddr) returns(bool){
         salary = salary * 1 ether;
         totalSalary += salary;
         employees[employeeAddr] = Employee(employeeAddr,salary,now);
         return true;
    }

    // 删除人员 
    function removeEmployee(address employeeAddr) onlyAdmin employeeAddressNotNull(employeeAddr){
        //如若有支付的工资则先 支付， 可能会出现未支付的情况，暂不做处理 
        bool ispay = _partialPaid(employee);
        totalSalary -= employee.salary;
         //删除元素并填补空白元素 
        delete(employees[employeeAddr]);
    }
    
    //更新员工薪资
    function updateEmployeeSalary(address employeeAddr,uint salary) onlyAdmin employeeAddressNotNull(employeeAddr){
        //如若有支付的工资则先支付 
        bool ispay = _partialPaid(employee);
        if(ispay) { //未支付则不更新最后支付时间 
            employee.lastPayDay = now;
        }
        totalSalary -= employee.salary;
        totalSalary += salary * 1 ether;
       employee.salary = salary * 1 ether;
        
    }
    
    //更新员工地址
    function changePaymentAddress(address oldAddr,address newAddr) onlyAdmin employeeAddressNotNull(oldAddr){
        employee.employeeAddress = newAddr;
        employees[newAddr] = employee;
        
    }
    
    
    //添加资金 
    function addFund() payable returns (uint){
        return this.balance;
    }
    
      //是否够发放当前工资 
    function hasEnoughFund() returns (bool){
        return calculateRunway() > 0;
    }


    //领取工资 
    function getPaid(address employeeAddr) employeeAddressNotNull(employeeAddr) {
        require(msg.sender == employeeAddr);
        uint nextPayDay = employee.lastPayDay + payDuration;
        if(nextPayDay > now){
            revert();
        }
        employee.lastPayDay = nextPayDay;
        employeeAddr.transfer(employee.salary);
    }

    //计算合约balance还能支付的次数
   
    function calculateRunway() returns (uint){
        return this.balance / totalSalary;
    }
 
}

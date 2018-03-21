pragma solidity ^0.4.14;
contract Payroll {
    
    address contractOwner ; //智能合约创建者，工资系统管理员
	uint totalSalary ;
    
    function  Payroll(){
        contractOwner = msg.sender ;
		totalSalary = 0 ;
    }
    
    struct Employee{
        address employeeId;
        uint salary;
        uint lastPayDay;
    }
    
    Employee[] employees;
  
    uint constant payDuration = 10 seconds;
    

    
    // 统一支付方法 
    function _partialPaid(Employee e) private returns (bool){
        uint payment = e.salary * (now - e.lastPayDay) / payDuration;
        if(payment > 0){
            e.employeeId.transfer(payment);
            return true;
        }else{
            return false;
        }
    }
    
    function _findEmployee(address employeeId) private returns (Employee,uint){
        for(uint i = 0; i < employees.length; i++){
            if(employees[i].employeeId == employeeId){
                return (employees[i],i);
            }
        }
    }
    
    //添加员工
    function addEmployee(address employeeId,uint salary)  {
		 require(msg.sender == contractOwner);
         var (employee,index) = _findEmployee(employeeId);
         assert(employee.employeeId == 0x0);
         salary = salary * 1 ether;
		 //update  totalSalary when add a employee
         totalSalary += salary * 1 ether;
         employees.push(Employee(employeeId,salary,now));
		 
    }
    
    // 删除员工
    function removeEmployee(address employeeId) {
		require(msg.sender == contractOwner);
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.employeeId != 0x0);
        _partialPaid(employee);
		//update  totalSalary when remove a employee
        totalSalary -= employees[index].salary * 1 ether;
         
         //删除元素并填补空白元素 
        delete(employees[index]);
		if(index != employees.length -1){
			employees[index] = employees[employees.length -1];
        }
		employees.length = employees.length -1;
		
		
    }
    
    //更新员工薪资
    function updateEmployeeSalary(address employeeId,uint salary)  {
		require(msg.sender == contractOwner);
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.employeeId != 0x0);
		//update totalSalary when update employee salary
		totalSalary = totalSalary + salary * 1 ether - employees[index].salary;
        //如若有支付的工资则先支付 
        bool ispay = _partialPaid(employee);
        if(ispay){ //未支付则不更新最后支付时间 
            employees[index].lastPayDay = now;
        }
        employees[index].salary = salary * 1 ether;
		
        
    }
    
    //更新员工地址
    function updateupdateemployeeId(address oldAddr,address newAddr) {
		require(msg.sender == contractOwner);
        var (employee,index) = _findEmployee(oldAddr);
        assert(employee.employeeId != 0x0);
        employees[index].employeeId = newAddr;
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
    function getPaid(address employeeId) returns (uint){
        require(msg.sender == employeeId);
        
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.employeeId != 0x0);
        
        uint nextPayDay = employee.lastPayDay + payDuration;
        if(nextPayDay > now){
            revert();
        }
        employees[index].lastPayDay = nextPayDay;
        employeeId.transfer(employees[index].salary);
    }
    
    
     
    //计算合约balance还能支付的次数 
    function calculateRunway() returns (uint value){
        return this.balance /totalSalary ;
    }
    
    /**
     * 
     * 
     * 每添加一个员工后calculateRunway函数的gas消耗情况
     *    次数  transactionCost    executionCost           
     *    1		105214				82342          
     *    2		91055				68183 
     *    3		91896				69024 
     *    4 	92737				69865 
     *    5		93578 				70706   
     *    6		94419				71547
     *    7		95260				72388 
     *    8		96101				73229
     *    9		96942				74070
     *    10	97783				74911 
     * 
     *    gas每添加一个员工后都是有变化的，因为存储在storage里面的数据在增加，每次读取storage的成本是增加的 
     *
     **/
   
}
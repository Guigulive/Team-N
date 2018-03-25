var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
    // 1. test addEmployee function by owner      
    it("add employee for test", function() {
        return Payroll.deployed().then(function(instance){
            payrollInstance = instance;
            payrollInstance.addEmployee(accounts[1],1,{from:accounts[0]});
        }).then(function(){
            return payrollInstance.employees.call(accounts[1]);
        }).then(function(employee){
            assert.equal(employee[0],accounts[1],"add account1 successful");
        });
      });
   

      // 2. test addEmployee function by nonowner   
      it("add employee by nonowner for test", function () {
        return Payroll.deployed().then(function (instance) {
            payrollInstance = instance;
            exception = false;
            return payrollInstance.addEmployee(accounts[1], 1, { from: accounts[1] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true, "add failed by nonowner");
        });
    });

    it("remove employee for test", function () {
        return Payroll.deployed().then(function (instance) {
            payrollInstance = instance;
            return payrollInstance.addEmployee(accounts[2], 1,{from:accounts[0]});
        }).then(function () {
            return payrollInstance.employees.call(accounts[2]);
        }).then(function (employee) {
            add_employee = employee[0];
         }).then(function () {
            payrollInstance.removeEmployee(accounts[2],{from:accounts[0]});
         }).then(function () {
             return payrollInstance.employees.call(accounts[2]);
         }).then(function (employee) {
             rm_employee = employee[0];
        }).then(function () {
            assert.equal(add_employee, accounts[2], "add successful");
            assert.equal(rm_employee, 0, "remove successful");
        });
    });


});

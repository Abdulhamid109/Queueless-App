import 'package:flutter/material.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';
import 'package:queueless/worker/workerloginScreen.dart';

class WorkerAppbar extends StatelessWidget implements PreferredSizeWidget{
  const WorkerAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue.shade100,
      title: Text("Worker Panel"),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.red
                            ),
            onPressed: (){
            showDialog(
              barrierDismissible: false,
              context: context, builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Are you sure you want to logout?",style: TextStyle(fontSize: 18),textAlign: TextAlign.center,),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.red,
                    
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text("Tip : Once you logout your session will be inactive and all the customer will be at halt",style: TextStyle(color: Colors.white,fontSize: 14),)),
                      )),
                  ],
                                  ),
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.grey.shade300
                            ),
                            onPressed: ()=>Navigator.pop(context), child: Text("Cancel")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.red
                            ),
                      onPressed: ()async{
                        await onhandleLogout(context, Workerloginscreen());
                      }, child: Text("Logout",style: TextStyle(color: Colors.white),))
                        ],
                      ),
                    )
                  ],
                );
          
            },);
          }, child: Text("Logout",style: TextStyle(color: Colors.white),)),
        )
      
      ],
    );
  }
}
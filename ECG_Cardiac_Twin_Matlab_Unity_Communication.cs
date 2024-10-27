using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Net;
using System.Net.Sockets;
using System.Linq;
using System;
using System.IO;
using System.Text;

public class Communication : MonoBehaviour
{
    // Start is called before the first frame update
    private Animator playerAnim;

    TcpListener listener;
    public static String msg;
    public static char[] delimiter = new char[] { ' ' };
    //public static string[] information;
    String msg2;

    public float status_P_i = 0;
    public float status_P_f = 0;
    public float status_S_i = 0;
    public float status_S_f = 0;
    public float status_T_i = 0;
    public float status_T_f = 0;
    public float status_R_i = 0;
    public float status_R_f = 0;

    private float scaleFactor;
    private float Number;
    private Vector3 myVector;
    private Vector3 origin;

    // Start is called before the first frame update
    void Start()
    {
        playerAnim = GetComponent<Animator>();

        //listener=new TcpListener (55001);
        listener = new TcpListener(IPAddress.Parse("127.0.0.1"), 55001);
        listener.Start();
        print("is listening");


    }

    void Update()
    {
        string msg_dummy = "shit happend";

        if (!listener.Pending())
        {
        }
        else
        {
            //print("socket comes");
            TcpClient client = listener.AcceptTcpClient();
            NetworkStream ns = client.GetStream();
            StreamReader reader = new StreamReader(ns);
            msg = reader.ReadToEnd();
            //print(msg);

        }

        if (msg != null)
        {
            msg_dummy = msg;
            string[] output = msg.Split(delimiter);
            //Debug.Log("position is " + output[1]);
            scaleFactor = float.Parse(output[2]);


            switch (output[1])
            {
                case "P":
                    status_P_i = 1;
                    status_S_i = 0;
                    status_T_i = 0;
                    status_R_i = 0;
                    break;

                case "S":
                    status_P_i = 0;
                    status_S_i = 1;
                    status_T_i = 0;
                    status_R_i = 0;
                    break;

                case "T":
                    status_P_i = 0;
                    status_S_i = 0;
                    status_T_i = 1;
                    status_R_i = 0;
                    break;

                case "R":
                    status_P_i = 0;
                    status_S_i = 0;
                    status_T_i = 0;
                    status_R_i = 1;
                    break;

            }

        }
        else
        {
            msg_dummy = " ";
        }

        Number = scaleFactor + 1; Number = scaleFactor + 1;

        myVector = new Vector3(Number, Number, Number);
        origin = new Vector3(1,1,1);


        if (status_P_i != status_P_f)
        {
            status_P_f = status_P_i;
            if (status_P_i == 1)
            {
                print("P-wave");
                playerAnim.SetBool("P", true);
                playerAnim.SetBool("S", false);
                playerAnim.SetBool("T", false);
                transform.localScale = origin;
            }

        }

        if (status_S_i != status_S_f)
        {
            status_S_f = status_S_i;
            if (status_S_i == 1)
            {
                print("S-wave");
                playerAnim.SetBool("P", false);
                playerAnim.SetBool("S", true);
                playerAnim.SetBool("T", false);
                transform.localScale = origin;
            }

        }

        if (status_T_i != status_T_f)
        {
            status_T_f = status_T_i;
            if (status_T_i == 1)
            {
                print("T-wave");
                playerAnim.SetBool("P", false);
                playerAnim.SetBool("S", false);
                playerAnim.SetBool("T", true);
                transform.localScale = origin;
            }

        }

        if (status_R_i == 1)
        {
            transform.localScale = myVector;
        }

        if (status_R_i != status_R_f)
        {
            status_R_f = status_R_i;
            if (status_R_i == 1)
            {
                print("Rest");
                playerAnim.SetBool("P", false);
                playerAnim.SetBool("S", false);
                playerAnim.SetBool("T", false);
               
            }

        }

       

    }
}

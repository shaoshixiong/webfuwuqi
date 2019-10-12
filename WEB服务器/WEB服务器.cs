using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using System.IO;

namespace WEB服务器
{
    public partial class WEB服务器 : Form
    {
        bool isListen = true;

        Socket socket;

        public WEB服务器()
        {
            InitializeComponent();
            TextBox.CheckForIllegalCrossThreadCalls = false;
        }

        #region 1.0 开启服务 - btnStart_Click(object sender, EventArgs e)
        /// <summary>
        /// 1.0 开启服务
        /// </summary>
        private void btnStart_Click(object sender, EventArgs e)
        {
            socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPAddress ipaddress = IPAddress.Parse(txtIPAddress.Text.Trim());
            IPEndPoint endpoint = new IPEndPoint(ipaddress, int.Parse(txtPort.Text.Trim()));
            socket.Bind(endpoint);
            Thread thread = new Thread(Accept);
            thread.IsBackground = true;
            thread.Start();
            ShowInfo("服务已启动！！！");
            btnStart.Enabled = !btnStart.Enabled;
        }
        #endregion

        #region 2.0 等待客户端连接 - Accept()
        /// <summary>
        /// 2.0 等待客户端连接
        /// </summary>
        private void Accept()
        {
            while (isListen)
            {
                socket.Listen(10);
                Socket newSocket = socket.Accept();
                MsgConnection msgConn = new MsgConnection(newSocket, ShowInfo);
            }
        }
        #endregion

        #region 3.0 显示消息 - ShowInfo(string strMsg)
        /// <summary>
        ///  3.0 显示消息
        /// </summary>
        private void ShowInfo(string strMsg)
        {
            txtMsg.AppendText(strMsg + "\r\n");
        }
        #endregion

        #region 4.0 添加上传路径 -  txtPath_Click(object sender, EventArgs e)
        private void txtPath_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                this.txtPath.Text = ofd.FileName;
            }
        }
        #endregion

        #region 5.0 复制 - btnUpload_Click(object sender, EventArgs e)
        private void btnUpload_Click(object sender, EventArgs e)
        {
            try
            {
                string path = txtPath.Text.Trim();
                if (path == "点击添加静态页面" || string.IsNullOrEmpty(path))
                {
                    MessageBox.Show("请选择文件");
                }
                else
                {
                    File.Copy(this.txtPath.Text, AppDomain.CurrentDomain.BaseDirectory + Path.GetFileName(this.txtPath.Text));
                    MessageBox.Show("上传成功！");
                }
            }
            catch
            {
                MessageBox.Show("上传出错！");
            }
        }
        #endregion
    }
}

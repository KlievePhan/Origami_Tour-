using System.Net;
using System.Net.Mail;
using Backend.Services.Interfaces;
using Microsoft.Extensions.Configuration;

namespace Backend.Services
{
    public class MailService : IMailService
    {
        private readonly IConfiguration _config;

        public MailService(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            var host = _config["Email:SmtpHost"];
            var port = int.Parse(_config["Email:SmtpPort"] ?? "587");
            var username = _config["Email:Username"];
            var password = _config["Email:Password"];

            using var client = new SmtpClient(host, port)
            {
                Credentials = new NetworkCredential(username, password),
                EnableSsl = true
            };

            var mailMessage = new MailMessage
            {
                From = new MailAddress(username!, "Origami Tour"),
                Subject = subject,
                Body = body,
                IsBodyHtml = true
            };

            mailMessage.To.Add(toEmail);

            await client.SendMailAsync(mailMessage);
        }
    }
}

using DevOpsAssignment;
using DevOpsAssignment.Controllers;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using System.Collections.Generic;

namespace SampleAPI.Tests.Controllers
{
    [TestClass]
    public class WeatherForecastControllerTests
    {
        [TestMethod]
        public void Get_Returns_Message()
        {
            var controller = new WeatherForecastController(new Mock<ILogger<WeatherForecastController>>().Object);
            var result = controller.GetMessage();
            Assert.IsInstanceOfType(result, typeof(string));
        }

        [TestMethod]
        public void Get_Returns_ListOfWeatherForecast()
        {
            var controller = new WeatherForecastController(new Mock<ILogger<WeatherForecastController>>().Object);
            var result = controller.GetWeatherForecastList();
            Assert.IsInstanceOfType(result, typeof(IEnumerable<WeatherForecast>));
        }
    }
}

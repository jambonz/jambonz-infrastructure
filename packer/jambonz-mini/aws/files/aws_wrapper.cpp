#include <aws/core/Aws.h>
#include <aws/core/utils/logging/DefaultLogSystem.h>
#include <aws/core/utils/logging/AWSLogging.h>

// C-compatible wrapper functions
extern "C" {
  const char ALLOC_TAG[] = "jambonz";

  void aws_init_api() {
    const char* awsTrace = std::getenv("AWS_TRACE");
    Aws::SDKOptions options;
    options.httpOptions.installSigPipeHandler = true;

    if (awsTrace && 0 == strcmp("1", awsTrace)) {
      options.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Trace;

      Aws::Utils::Logging::InitializeAWSLogging(
          Aws::MakeShared<Aws::Utils::Logging::DefaultLogSystem>(
            ALLOC_TAG, Aws::Utils::Logging::LogLevel::Trace, "aws_sdk_"));
    }

    Aws::InitAPI(options);
  }

  void aws_shutdown_api() {
		Aws::SDKOptions options;
		
    const char* awsTrace = std::getenv("AWS_TRACE");
    if (awsTrace && 0 == strcmp("1", awsTrace)) {
        options.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Trace;
        Aws::Utils::Logging::ShutdownAWSLogging();
    }
    Aws::ShutdownAPI(options);
  }
}

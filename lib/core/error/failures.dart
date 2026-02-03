abstract class Failure {
  final String message;
  final int? statusCode;
  Failure(this.message, {this.statusCode});
}

class ServerFailure extends Failure {
  ServerFailure(super.message, {super.statusCode});
}

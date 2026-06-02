import SwiftUI

struct RunwayConsentEULADialog: View {
    let runwayConsentCancelAction: () -> Void
    let runwayConsentAgreeAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.58)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.clear)
                    .frame(height: 0)

                Text("EULA")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    .padding(.top, 30)
                    .padding(.bottom, 22)

                ScrollView(showsIndicators: false){
                    Text("This End User License Agreement (hereinafter referred to as the \"Agreement\") constitutes a legally binding contract between you and Sarty Platform (hereinafter referred to as \"us\") governing your use of Sarty. By downloading, installing and using this application, you voluntarily accept all terms of this Agreement.\n\n1. User Content RulesAll outfit images, texts, videos, chat records and other content posted by users on the APP shall be legal and compliant, free from infringement, vulgarity, violence, false or illegal information. You grant us the free, worldwide right to use, display, review and remove your user content for platform operation and service optimization. We reserve the right to delete, restrict the exposure of or block any violating content and accounts.\n2. Intellectual Property RightsAll interfaces, codes, logos, functions and related intellectual property rights of this APP are owned by us and protected by applicable laws. Without our prior written consent, users shall not use them for commercial purposes or engage in unauthorized appropriation.\n3. Privacy ProvisionsYour use of this service signifies your consent to our collection and use of your relevant information in accordance with the Privacy Policy, which forms an integral part of this Agreement.\n4. Disclaimer and TerminationThis application is provided on an \"as-is\" basis. We do not guarantee uninterrupted or error-free service at all times, and shall not be liable for any indirect losses incurred by users. \n\nIf you use the application in violation of relevant rules, we have the right to unilaterally terminate your access permission and block your account without prior notice.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk.opacity(0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 18)
                }

                Spacer()

                HStack(spacing: 20) {
                    Button {
                        runwayConsentCancelAction()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        runwayConsentAgreeAction()
                    } label: {
                        Text("Agree")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(LookbookShareColorStyle.runwayGlowYellow)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 495)
            
            .background(
                LinearGradient(
                    stops: [
                        .init(color: LookbookShareColorStyle.runwayGlowYellow.opacity(0.88), location: 0),
                        .init(color: Color(red: 1.0, green: 0.91, blue: 0.62), location: 0.22),
                        .init(color: LookbookShareColorStyle.lookbookSoftCanvas, location: 0.48),
                        .init(color: LookbookShareColorStyle.lookbookSoftCanvas, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(HemlineCurveTopCornerShape(hemlineCurveCornerRadius: 24))
            .ignoresSafeArea(edges: .bottom)
        }.ignoresSafeArea()
        .transition(.opacity)
    }
}
